
# Resolving SSH "Permission Denied (publickey)" for Jenkins

This guide will walk through resolving the "Permission denied (publickey)" error when trying to SSH from a Jenkins master server to a remote worker server.

---

## Step 1: Ensure Jenkins User Exists on the Remote Server

1. **Check if the Jenkins User Exists**:
   
   Run the following command on the remote server (`ip-172-31-11-163`) to see if the `jenkins` user exists:
   ```bash
   cat /etc/passwd | grep jenkins
   ```
   If the user exists, you should see a line like:
   ```bash
   jenkins:x:1001:1001::/home/jenkins:/bin/bash
   ```

2. **Recreate the Jenkins User (if necessary)**:
   
   If the `jenkins` user doesn’t exist or the home directory is incorrect, delete and recreate the user:
   ```bash
   sudo userdel -r jenkins
   sudo useradd -m -d /home/jenkins -s /bin/bash jenkins
   ```
   This creates the user `jenkins` with the home directory `/home/jenkins`.

3. **Set a Password for the Jenkins User**:
   
   Set a password for the user (useful for troubleshooting):
   ```bash
   sudo passwd jenkins
   ```

---

## Step 2: Generate and Configure SSH Keys on the Master Server

1. **Switch to Jenkins User**:

   On the Jenkins master server, switch to the Jenkins user:
   ```bash
   sudo su -s /bin/bash jenkins
   ```

2. **Generate SSH Keys** (if they don't already exist):
   ```bash
   ssh-keygen -t rsa -b 4096
   ```
   Press Enter to accept the default location (`/var/lib/jenkins/.ssh/id_rsa`).

3. **Start the SSH Agent and Add the SSH Key**:
   
   Start the SSH agent and add the SSH key:
   ```bash
   eval \$(ssh-agent -s)
   ssh-add ~/.ssh/id_rsa
   ```

---

## Step 3: Copy the SSH Public Key to the Remote Server

1. **Manually Copy the Public Key**:
   
   On the Jenkins master server, display the public key:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

2. **Log in to the Remote Server and Add the Key**:
   
   Log into the remote server (`ip-172-31-11-163`) using another user (e.g., `ubuntu`):
   ```bash
   ssh ubuntu@ip-172-31-11-163
   ```

   Once logged in, append the public key to the `authorized_keys` file:
   ```bash
   mkdir -p /home/jenkins/.ssh
   echo "<your-public-key>" >> /home/jenkins/.ssh/authorized_keys
   chmod 600 /home/jenkins/.ssh/authorized_keys
   chmod 700 /home/jenkins/.ssh
   chown -R jenkins:jenkins /home/jenkins/.ssh
   ```

---

## Step 4: Ensure Correct Permissions on Both Servers

1. **On the Jenkins Master**:
   
   Run the following to ensure correct permissions on the `.ssh` directory and files:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   ```

2. **On the Remote Server**:
   
   Ensure correct permissions for the `jenkins` user’s `.ssh` directory and files:
   ```bash
   chmod 700 /home/jenkins/.ssh
   chmod 600 /home/jenkins/.ssh/authorized_keys
   chown -R jenkins:jenkins /home/jenkins/.ssh
   ```

---

## Step 5: Test the SSH Connection

Now, on the Jenkins master server, as the `jenkins` user, test the connection:
```bash
ssh jenkins@ip-172-31-11-163
```
If the connection works without a password prompt, the SSH setup is successful.

---

## Step 6: Troubleshoot Using Verbose SSH Output

If the connection fails, use the verbose option for more information:
```bash
ssh -v jenkins@ip-172-31-11-163
```

This will provide detailed output on the authentication process.

---

### Common Fixes:
- Ensure the SSH public key is correctly added to `/home/jenkins/.ssh/authorized_keys`.
- Ensure correct permissions for `.ssh` directories and files (no more open than `700` for directories and `600` for files).
- If `sshd_config` is modified, restart the SSH service on the remote server:
  ```bash
  sudo systemctl restart ssh
  ```

By following these steps, you should be able to resolve the SSH "Permission denied (publickey)" issue between Jenkins and the remote server.

