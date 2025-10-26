Below is a ready-to-run Terraform example that creates a MongoDB Atlas free-tier (M0) cluster, creates a DB user, and outputs a ready-to-use connection string (including username — password kept as a sensitive variable). I also include short usage instructions and important caveats (with sources).
I used the official MongoDB Terraform provider resources and the Atlas attributes that expose connection strings. registry.terraform.io+2registry.terraform.io+2

What this will do


Create a MongoDB Atlas Project (in an existing Organization).


Create an M0 (free) cluster in that project.


Create a database user (username + password).


Output the SRV connection string (mongodb+srv) with username (password is intentionally not printed raw — see notes).
(You can still output the full URI if you want, but I recommend keeping the password secure.)


Key provider & attribute references: the provider exposes connection_strings on cluster/advanced_cluster data/resources which we use to build the URI. registry.terraform.io+1

Prerequisites


Terraform installed (recommended >= 1.2).


A MongoDB Atlas account.


An Atlas Organization ID and an Atlas API key (public & private keys) with permissions to create projects & clusters. See Atlas docs to create API keys. MongoDB



Files
Create a directory (e.g. terraform-mongo-atlas) and add these files.
1) provider.tf


2) variables.tf

3) main.tf


Note: the provider offers mongodbatlas_advanced_cluster and mongodbatlas_cluster. Both expose connection_strings. The advanced resource is recommended for new configs, but mongodbatlas_cluster supports M0. registry.terraform.io+1

4) outputs.tf


How to run (recommended)


Put your Atlas API keys and other secrets in a secure place — do not commit them.


E.g., use environment variables:
export TF_VAR_atlas_public_key="ATLAS_PUBLIC_KEY"
export TF_VAR_atlas_private_key="ATLAS_PRIVATE_KEY"
export TF_VAR_org_id="YOUR_ORG_ID"
export TF_VAR_db_password="super-secret-password"



Or create a terraform.tfvars (but keep it out of VCS).




Initialize & apply:
terraform init
terraform apply

Confirm the plan. Atlas may take a moment to create the M0 cluster.


View outputs:


Non-sensitive:
terraform output mongodb_srv
terraform output mongodb_uri_with_username



Sensitive full URI (printed locally):
terraform output -raw mongodb_uri_full_sensitive



Use the full URI locally in your app (or fetch password from your secret manager).



Important notes & caveats


One M0 per project: Atlas only allows one free (M0) cluster per project. If you already have one in the chosen project, creation will fail. Consider creating a new project. MongoDB


Region constraints: Not all regions support M0. If Terraform errors on region, pick another cluster_region that Atlas supports for M0. The Atlas UI/docs list supported regions. MongoDB


Provider choice: Some provider versions changed resource names and behavior — the docs recommend mongodbatlas_advanced_cluster for new setups, but mongodbatlas_cluster is still commonly used, and connection_strings is available as shown above. If you prefer the advanced resource, the same connection_strings attributes exist. registry.terraform.io+1


Password handling: I marked password as sensitive = true. Avoid writing it into plain files or CI logs. Instead, use a secret manager (Vault/Secrets Manager) or Terraform Cloud variables.


Timing: Cluster provisioning may take a few minutes. The data lookup for connection strings might be empty until Atlas finishes creating the cluster — Terraform will wait, but if you see known after apply you can run terraform apply again or query via the Atlas UI/CLI once creation completes. MongoDB



If you want the exact mongodbatlas_advanced_cluster variant
I can convert the mongodbatlas_cluster resource to mongodbatlas_advanced_cluster (recommended if you want the newer API surface and more explicit config). The connection_strings attribute is the same and you can output data.mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv. registry.terraform.io+1

Quick troubleshooting tips


403 or permission errors: ensure the Atlas API key has project creation & cluster creation rights (Organization Owner or Project Creator). Medium


region not supported or M0 not available: change cluster_region to a supported M0 region for your cloud provider. Use the Atlas UI to check M0-supported regions. MongoDB


If connection string looks like mongodb+srv://<host> without credentials — that’s expected: SRV host is separate; add username/password when connecting. Many drivers accept mongodb+srv://user:pass@host/db?options.



If you want, I can:


produce the same set of files but using mongodbatlas_advanced_cluster instead (recommended), or


output a secure example using HashiCorp Vault / AWS Secrets Manager to supply the DB password, or


generate a small script that waits until the cluster connection string is ready and prints the final full URI (careful with secrets).


Which of those would you like next?
You said:public and private key means clientid and client secret or is there any other 

How to generate it from mangodb portalChatGPT said:Great question — this confuses a lot of people, because MongoDB Atlas uses “Public Key” and “Private Key” terminology for its API programmatic access, while many other platforms (like OAuth clients or cloud providers) use “Client ID / Client Secret.”
Let’s clear it up precisely:

🧩 MongoDB Atlas Public Key vs Private Key


They are not the same as “Client ID” / “Client Secret.”


Instead, they’re API keys used to authenticate Terraform, mongocli, or other programmatic access to your MongoDB Atlas organization.


You’ll generate these keys in the MongoDB Atlas UI → Organization Settings → Access Manager → API Keys.

🪪 What They Represent
Atlas TermAnalogyPurposePublic Keylike a usernameIdentifies your API key (safe to store in Terraform var, but not public).Private Keylike a password / secretUsed to sign API requests (keep this secret).
Together, they let Terraform authenticate as an Atlas programmatic user that has permissions to create Projects, Clusters, Users, etc.

🔧 How to Generate Atlas Public & Private Keys
Step-by-step (from MongoDB Atlas Portal)


Log in to your Atlas account:
👉 https://cloud.mongodb.com


In the top-left organization dropdown, choose the organization level (not just a single project).


Go to
Organization Access → API Keys
or sometimes under
Access Manager → Organization Access → API Keys


Click “Create API Key”.


Choose:


Description (e.g. terraform-automation)


Organization Permissions → select at least:


Project Creator (to create projects)


Org Read Only (if you just need to query)


or Organization Owner (if you need full control)






Click Next → Create API Key.


Copy the keys immediately — Atlas shows:


Public Key → e.g. ab12cd34


Private Key → e.g. 1234abcd-5678-ef90-ghij-1234567890ab


⚠️ The Private Key is shown only once. Copy it safely into your password manager or secret manager.


You can also restrict IP Access List for security (recommended: add your CI/CD runner IPs).



✅ Using the keys in Terraform
You’ll set them as variables (sensitive):
export TF_VAR_atlas_public_key="ab12cd34"
export TF_VAR_atlas_private_key="1234abcd-5678-ef90-ghij-1234567890ab"

Or in terraform.tfvars (don’t commit this file):
atlas_public_key  = "ab12cd34"
atlas_private_key = "1234abcd-5678-ef90-ghij-1234567890ab"

Then Terraform uses them via the provider:
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}


🔒 Security Best Practices


Treat the Private Key as sensitive like any other secret (Vault, Secrets Manager, GitHub Actions secret, etc.).


Never check it into Git.


Restrict the API key’s IP access list to your CI/CD servers or corporate CIDRs.


Use organization-level API keys for infra provisioning (Terraform), not user-level ones.



🧠 Summary
FieldSourceWhat it’s used forPublic KeyAtlas UI (Org Access → API Keys)“Username” for API accessPrivate KeyAtlas UI (shown once when you create the key)“Password/Secret” for API accessOrg IDFound in Organization SettingsUsed by Terraform to know which Org to create a project in
So:
➡️ Public Key ≈ Client ID
➡️ Private Key ≈ Client Secret
✅ but specific to MongoDB Atlas’s API, not OAuth.

Would you like me to show screenshots / UI navigation path for where these keys appear in the Atlas portal (visually explained with placeholders)? I can generate a diagram to make it crystal clear.