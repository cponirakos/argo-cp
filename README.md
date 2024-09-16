# argo-cp
Reference blog:
https://vrelevant.net/crossplane-and-gitops-lets-get-to-the-good-stuff/


Steps:
1. Create a kind cluster
2. Run the shell scripts on "env-setup-scripts/" to deploy ArgoCD and Crossplane
3. Run "kubectl port-forward svc/argocd-server -n argocd 8080:443" to expose ArgoCD UI on a browser
4. Create a k8s secret with AWS credentials to configure the AWS provider ("kubectl create secret generic aws-creds -n upbound-system --from-file=creds=./creds.conf")
5. Setup the private Github Repo
6. Apply the ArgoApps manifests from "argoapps/"

