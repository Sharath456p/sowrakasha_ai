#!/bin/bash
set -e

# CONFIGURATION
PROJECT_ID="sowrakasha-ai-platform"
REGION="us-central1"
REPO_NAME="" # Set this or input it
SA_NAME="github-actions-sa"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

# COLORS
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Sowrakasha.ai: GitOps Bootstrap (No Local Terraform)${NC}"

# 1. Input Validation
if [ -z "$GITHUB_REPO" ]; then
    read -p "Enter GitHub Repo (username/repo): " GITHUB_REPO
fi

# 2. Enable APIs
echo -e "${BLUE}🔹 Enabling APIs...${NC}"
gcloud services enable iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    compute.googleapis.com \
    iamcredentials.googleapis.com \
    --project "$PROJECT_ID"

# 3. Create State Bucket (Permanent Storage)
BUCKET_NAME="${PROJECT_ID}-tfshell"
if ! gcloud storage buckets list gs://$BUCKET_NAME --project "$PROJECT_ID" > /dev/null 2>&1; then
    echo -e "${BLUE}🔹 Creating State Bucket: $BUCKET_NAME${NC}"
    gcloud storage buckets create gs://$BUCKET_NAME --project "$PROJECT_ID" --location "$REGION"
else
    echo "✅ Bucket $BUCKET_NAME exists."
fi

# 4. Create Service Account (The "Builder" Identity)
if ! gcloud iam service-accounts describe ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --project "$PROJECT_ID" > /dev/null 2>&1; then
    echo -e "${BLUE}🔹 Creating Service Account: $SA_NAME${NC}"
    gcloud iam service-accounts create $SA_NAME --display-name "GitHub Actions IaC" --project "$PROJECT_ID"
else
    echo "✅ Service Account $SA_NAME exists."
fi

# Grant Admin permissions to this SA (It needs to create Clusters)
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/owner" > /dev/null
    # Note: 'roles/owner' is easiest for a lab. Use restrictive roles for prod.

# 5. Create Workload Identity Pool (The "Authenticator")
if ! gcloud iam workload-identity-pools describe $POOL_NAME --project "$PROJECT_ID" --location="global" > /dev/null 2>&1; then
    echo -e "${BLUE}🔹 Creating Identity Pool: $POOL_NAME${NC}"
    gcloud iam workload-identity-pools create $POOL_NAME \
        --project="$PROJECT_ID" \
        --location="global" \
        --display-name="GitHub Actions Pool"
else
    echo "✅ Identity Pool $POOL_NAME exists."
fi

# 6. Create Provider (The link to GitHub)
POOL_ID=$(gcloud iam workload-identity-pools describe $POOL_NAME --project "$PROJECT_ID" --location="global" --format="value(name)")

if ! gcloud iam workload-identity-pools providers describe $PROVIDER_NAME \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="$POOL_NAME" > /dev/null 2>&1; then
    
    echo -e "${BLUE}🔹 Creating OIDC Provider: $PROVIDER_NAME${NC}"
    gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
        --project="$PROJECT_ID" \
        --location="global" \
        --workload-identity-pool="$POOL_NAME" \
        --display-name="GitHub Actions OIDC" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --issuer-uri="https://token.actions.githubusercontent.com"
else
    echo "✅ Provider $PROVIDER_NAME exists."
fi

# 7. Bind IAM (Trust the Repo)
echo -e "${BLUE}🔹 Authorizing Repo: $GITHUB_REPO${NC}"
gcloud iam service-accounts add-iam-policy-binding "${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --project="$PROJECT_ID" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${POOL_ID}/attribute.repository/${GITHUB_REPO}" > /dev/null

# 8. Output Secrets
PROVIDER_FULL_PATH=$(gcloud iam workload-identity-pools providers describe $PROVIDER_NAME \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="$POOL_NAME" \
    --format="value(name)")

echo ""
echo -e "${GREEN}✅ Bootstrap Complete! No Terraform run locally.${NC}"
echo "Identity Infrastructure is permanently setup. Terraform on GitHub will handle the Cluster."
echo ""
echo -e "${BLUE}👇 ADD THESE SECRETS TO GITHUB:${NC}"
echo "GCP_PROJECT_ID = $PROJECT_ID"
echo "GCP_SERVICE_ACCOUNT = ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
echo "GCP_WORKLOAD_IDENTITY_PROVIDER = $PROVIDER_FULL_PATH"
echo ""
