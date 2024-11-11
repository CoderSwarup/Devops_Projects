# Kubernetes Cluster Setup on AWS EC2 with kubeadm

This guide provides a step-by-step process to set up a Kubernetes cluster with one master node and one worker node on AWS EC2 instances using **kubeadm**.

## Step 1: Launch EC2 Instances

1. **Launch Master and Worker EC2 Instances:**

   - Go to the AWS Console, navigate to EC2, and click on **Launch Instance**.
   - Choose **Amazon Linux 2** or **Ubuntu 20.04/22.04 LTS** as the base OS for your instances.
   - Select **t2.medium** or larger instance types for both the master and worker nodes.
   - Configure the security group to allow:
     - **SSH** (port 22) from your IP.
     - Kubernetes ports:
       - TCP 6443 (Kubernetes API server)
       - TCP 10250 (Kubelet communication)
       - TCP 179 (Calico or other CNI)
     - Allow all traffic between the instances in the cluster.
   - Launch the two instances (one master and one worker).
   - Note their Public IPs and SSH into them using:
     ```bash
     ssh -i "your-key.pem" ec2-user@<MASTER_IP>
     ```

2. **Install Docker** on both Master and Worker instances:

```sh
sudo apt update && sudo apt upgrade -y

# Set The Host Name
sudo hostnamectl set-hostname <master|worker>

sudo apt install -y docker.io

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
```

## Step 2: Install kubeadm, kubelet, and kubectl

[https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

1. **Disable swap** on both nodes:

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#/g' /etc/fstab
```

2. **Install Kubernetes tools** (kubeadm, kubelet, kubectl) on both nodes:

```bash
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Check that the kubectl and kubeadm is install or not
kubectl
kubeadm
```

## Step 3: Initialize the Master Node

1. **Initialize Kubernetes** on the master node:
   Replace `<MASTER_IP>` with the master's public IP.

```bash
sudo kubeadm init --apiserver-advertise-address=<MASTER_IP> --pod-network-cidr=192.168.0.0/16
```

2. **Set up kubectl** for the current user on the master node:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

3. **Install a Pod Network Add-On** (Calico) on the master node:

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

## Step 4: Join the Worker Node to the Cluster

1. **Get the join command** from the master node:

```bash
kubeadm token create --print-join-command
```

2. **Join the worker node** to the cluster:
   Run the join command output from the master on the worker node.

```bash
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

3. **Verify the worker node** has joined the cluster (on the master):

```bash
kubectl get nodes
```

## Step 5: Test the Cluster

1. **Deploy a sample NGINX application**:

```bash
kubectl create deployment nginx --image=nginx
```

2. **Expose the deployment**:

```bash
kubectl expose deployment nginx --port=80 --type=NodePort
```

3. **Check the pods**:

```bash
kubectl get pods -o wide
```

4. **Get the NodePort service**:

```bash
kubectl get svc
```

Access the NGINX service using the Node IP and the assigned NodePort.

## Step 6: Additional Considerations

- **Set up SSH key login** for secure access to EC2 instances.
- **Optional: Use a Load Balancer** for high availability by adding a load balancer in front of the master node.

By following these steps, you can successfully set up a Kubernetes cluster with one master and one worker node on AWS EC2 without using EKS.
