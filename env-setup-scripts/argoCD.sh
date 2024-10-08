# Usage: ./argoCD+Gatekeeper.sh [argo admin password]
#
# Use `chmod +x ./makeK8sUser.sh` to mark executable.
#
# Installs ArgoCD and OPA Gatekeeper. Three apps are created in ArgoCD, two for Crossplane and one for Gatekeeper.
# Install UXP before installing this script.
#
[ $# -eq 0 ] && { echo "Usage: ./argoCD+Gatekeeper.sh [argo admin password]"; exit 1; }
kubectl create namespace argocd
until kubectl get ns argocd -o 'jsonpath={..status.phase}' | grep -m 1 "Active" ; do : ; done
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.7/deploy/gatekeeper.yaml
# Use following line for RC version
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Use following line for released version
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "Hang tight, waiting for argoCD server to become ready. When you see the port-forward console open, you can access the argoCD UI at https://localhost:8080 with username admin and the password you provided."
until kubectl get pods -l app.kubernetes.io/name=argocd-server -n argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -m 1 "True"; do : ; done
#osascript -e 'tell app "Terminal" to do script "kubectl port-forward svc/argocd-server -n argocd 8080:443"'
export ARGO_ADMIN_PW=$1
export ARGO_NEW_PW=$(htpasswd -bnB "" $ARGO_ADMIN_PW | tr -d ':\n' | sed 's/$2y/$2a/')
kubectl -n argocd patch secret argocd-secret   -p '{"stringData": {"admin.password": "'$ARGO_NEW_PW'","admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
unset ARGO_NEW_PW
unset ARGO_ADMIN_PW
kubectl patch cm argocd-cm -p '{"data":{"application.resourceTrackingMethod":"annotation"}}' -n argocd