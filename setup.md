# Installing Kubernetes

## Prequisites:
### 1. Install kubectl
```shell
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 2. Install helm
```shell
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Install Kubernetes using K3s
### 1. Connect to one of the Linux node

### 2. Start the K3s server and connect it to the external datastore (if any) - in this case we'll use default SQLite
```bash
curl -sfL https://get.k3s.io |  INSTALL_K3S_VERSION=v1.31.8+k3s1 sh -s - server
```

### 3. Get main server node token:
```bash
cat /var/lib/rancher/k3s/server/token
```

### 4. Run command on your second K3s server node
```bash
curl -sfL https://get.k3s.io |  INSTALL_K3S_VERSION=v1.31.8+k3s1 sh -s - server \
    --token "K1096ea0aba144bb92513ee4e5c07ae00dc4bbf917693936796b88c0e71cdb253fa::server:9fcf6b59d9cba96a55afc6dbd42a39e1"
```

## Confirm that K3s is Running
- Run the following command on either of the K3s server nodes
```bash
sudo k3s kubectl get nodes
```

- Test the health of the cluster pods
```bash
sudo k3s kubectl get pods --all-namespaces
```

## Save and Start Using the kubeconfig File
### 1. Install kubectl, a Kubernetes command-line tool.
### 2. Setup kubeconfig
```bash
mkdir -p ~/.kube/config
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config/k3s.yaml
sudo chown -R ec2-user:ec2-user ~/.kube/config/k3s.yaml
vi ~/.bashrc
    # Use custom kubeconfig
    export KUBECONFIG=$HOME/.kube/config/k3s.yaml
    # Alias for kubectl
    alias k='kubectl'
    # Enable kubectl autocompletion
    source <(kubectl completion bash)
    # Enable completion for alias k
    complete -F __start_kubectl k

source ~/.bashrc
```
---

# ArgoCD
- Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

- Disable TLS of ArgoCD (Dev Environment)
```sh
kubectl edit cm -n argocd argocd-cmd-params-cm
# data:
#   server.insecure: "true"

kubectl rollout restart deployment -n argocd argocd-server
```

- Kustomizing Helm charts: to render Helm charts with Kustomize
```sh
kubectl edit -n argocd cm argocd-cm
# data:
#   kustomize.buildOptions: --enable-helm

kubectl rollout restart deployment -n argocd argocd-server
```

- Expose ArgoCD to external access:
```sh
kubectl port-forward -n argocd svc/argocd-server 8000:80 --address 0.0.0.0
```

- Get `admin` credential:
```sh
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---
# Rancher
## Install Rancher
### 1. Add the Helm Chart Repository
```sh
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
```

### 2. Create a Namespace for Rancher

This should always be cattle-system
```shell
kubectl create namespace cattle-system
```

### 3. Choose your SSL Configuration

The Rancher management server is designed to be secure by default and requires SSL/TLS configuration.
For this project, we choose Rancher-generated TLS certificate for simplifying TLS setup:

- `Configuration: Rancher Generated Certificates (Default)` <br />
- `Helm Chart Option: ingress.tls.source=rancher` <br />
- `Requires cert-manager: yes`


### 4. Install cert-manager

```sh
# If you have installed the CRDs manually, instead of setting `installCRDs` or `crds.enabled` to `true` in your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart: (optional)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/<VERSION>/cert-manager.crds.yaml


# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

### 5. Install Rancher with Helm and Your Chosen Certificate Option
- Testing environment can use fake domain name (production would require a real domain name)
`To fake the domain, use: <IP_OF_LINUX_NODE>.sslip.io`

- Install Rancher by helm

```shell
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=3.25.24.186.sslip.io \
  --set bootstrapPassword=admin
```

- If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:
```sh
echo https://172.31.0.14.sslip.io/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
# --> https://172.31.0.14.sslip.io/dashboard/?setup=admin
```

- To get just the bootstrap password on its own, run:
```sh
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
# --> admin
```

## Cleanup Rancher
### 1. Download script
```sh
git clone https://github.com/rancher/rancher-cleanup.git
cd rancher-cleanup
```

### 2. Using the cleanup script
#### Run as a Kubernetes Job
- Deploy the job using `kubectl create -f deploy/rancher-cleanup.yaml`
- Watch logs using `kubectl -n kube-system logs -l job-name=cleanup-job -f`

### 3. Verify
- Deploy the job using `kubectl create -f deploy/verify.yaml`
- Watch logs using `kubectl  -n kube-system logs -l job-name=verify-job  -f`, output should be empty (besides deprecation warnings)
- Check completed logs using `kubectl  -n kube-system logs -l job-name=verify-job  -f | grep -v "is deprecated"`, this will exclude deprecation warnings.

# Keycloak
## Expose Keycloak
```sh
kubectl port-forward -n keycloak svc/keycloak 8080:80 --address 0.0.0.0
```

## ArgoCD Keycloak Integration

### Diagram Keycloak works in an OIDC Authorization Code Flow with confidential client authentication
```text
+--------------------+             +---------------------+             +---------------------+
|     End-User       |             |       ArgoCD        |             |      Keycloak       |
|  (Browser session) |             |    (OIDC Client)    |             |   (OIDC Provider)   |
+--------------------+             +---------------------+             +---------------------+
         |                                   |                                     |
         | --- (1) Access ArgoCD UI ------>  |                                     |
         |                                   |                                     |
         |                                   | --- (2) Redirect to Keycloak ---->  |
         |                                   |      https://kc/auth?client_id=...  |
         |                                   |      &response_type=code            |
         |                                   |      &scope=openid                  |
         |                                   |      &redirect_uri=...              |
         | <--------- (3) Login Page --------|                                     |
         |                                   |                                     |
         | --- (4) User Enters Credentials ->|                                     |
         |                                   |                                     |
         |                                   | --- (5) Authenticate User --------> |
         |                                   |                                     |
         |                                   | <---- (6) Auth Success, Issue Code  |
         |                                   |      Redirect to ArgoCD callback    |
         | <------- (7) Redirect with Code --|                                     |
         |         https://argocd/auth/callback?code=abc123                        |
         |                                   |                                     |
         |                                   | --- (8) Exchange Code for Token --> |
         |                                   |     POST /token                     |
         |                                   |     grant_type=authorization_code   |
         |                                   |     code=abc123                     |
         |                                   |     client_id=argocd                |
         |                                   |     client_secret=*******           |
         |                                   |                                     |
         |                                   | <--- (9) Return Tokens -------------|
         |                                   |     ID token, Access token, etc.    |
         |                                   |                                     |
         | --- (10) Access ArgoCD with Token ---------------------------------->   |
         |                                   |                                     |

```

# Cert Manager
## Most common use cases:
### **1. Automatic TLS for Ingress**
* **What it does:** Automatically issues and renews TLS certificates for Kubernetes Ingress resources.
* **Example:**

  * You expose your service via NGINX Ingress and want HTTPS.
  * Cert-Manager requests a Let’s Encrypt certificate via HTTP-01 or DNS-01 challenge.
  * The certificate is stored in a Kubernetes `Secret` and mounted into the Ingress.
* **Benefit:** No manual cert generation or renewal — all automated.

### **2. Internal Service-to-Service Encryption**
* **What it does:** Issues certificates for internal services in a Kubernetes cluster.
* **Example:**

  * Microservices authenticate each other using mTLS.
  * Cert-Manager issues short-lived certs from a private CA (e.g., HashiCorp Vault, step-ca, or internal PKI).
* **Benefit:** Secure internal communication without manual cert rotation.

### **3. Certificate Lifecycle Management**
* **What it does:** Tracks expiry and automatically renews before certificates expire.
* **Example:**

  * A service uses a custom wildcard certificate for `*.dev.example.com`.
  * Cert-Manager renews it before expiry and updates the Kubernetes Secret transparently.
* **Benefit:** Prevents outages due to expired certificates.

### **4. Wildcard Certificate Automation**
* **What it does:** Issues wildcard certificates via DNS-01 challenges.
* **Example:**

  * One wildcard cert for `*.staging.example.com` to cover multiple apps.
  * Works with DNS providers like Route53, Cloudflare, Google Cloud DNS.
* **Benefit:** Single cert for many subdomains, easy rotation.

### **5. Integration with External PKI Systems**
* **What it does:** Acts as a bridge between Kubernetes and external certificate authorities.
* **Example:**

  * Use ACME (Let’s Encrypt), Venafi, HashiCorp Vault, or your corporate CA.
* **Benefit:** Consistent Kubernetes integration without manual cert requests.

### **6. Securing Webhooks and Custom Controllers**
* **What it does:** Automatically generates TLS certs for Kubernetes admission webhooks, CRDs, and controllers.
* **Example:**

  * When deploying a MutatingWebhookConfiguration, Cert-Manager handles the cert generation and CA injection.
* **Benefit:** Simplifies deployment of components that need HTTPS endpoints.

### **7. Developer Self-Service Certificates**
* **What it does:** Allows teams to request certificates via Kubernetes manifests (`Certificate` CRD).
* **Example:**

  * Developer writes:

    ```yaml
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: my-app-cert
    spec:
      secretName: my-app-tls
      issuerRef:
        name: letsencrypt-prod
        kind: ClusterIssuer
      dnsNames:
      - myapp.example.com
    ```
  * Cert-Manager provisions it automatically.
* **Benefit:** No direct access to CA or cert tooling needed.
