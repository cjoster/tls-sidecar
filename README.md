# TLS Sidecar

This project is a small nginx sidecar for transparently enabling
TLS in a pod that otherwise does not support it. Simply run this container
next to the existing container, match up the ports, and your app is
TLS-passthrough ready.

# Steps to deploy

## Create a TLS key/cert pair

This step is only necessary if you don't already have a certificate. This creates
a self-signed certificate for testing.

```bash
openssl genrsa 4096 > tls.key
openssl req -new -x509 -key tls.key -subj "/C=US/ST=California/L=Palo Alto/O=VMware, Inc./OU=Tanzu Labs/" \
    -addext "subjectAltName = DNS: server.example.com" -addext "basicConstraints = CA:TRUE,pathlen:0" -out tls.crt
```

## Create the TLS secret

```bash
kubectl config set-context --current --namespace=<NAMESPACE>
kubectl create secret tls myapp-tls --cert=tls.crt --key=tls.key
```

## Add the TLS sidecar

Under `spec.template.spec.containers`, add 

```yaml
+      - name: tls-sidecar
+        image: docker.io/cjoster/tls-sidecar:0.1a
+        imagePullPolicy: IfNotPresent
+        env:
+        - name: HTTP_PORT
+          value: "8080" # Unencrypted port the other container is listening on
+        - name: HTTPS_PORT
+          value: "8443" # Secure port we're going to use
+        ports:
+        - containerPort: 8443 # Same secure port
+          name: https
+          protocol: TCP
+        securityContext:
+          allowPrivilegeEscalation: false
+          readOnlyRootFilesystem: true
+          capabilities:
+            drop:
+            - ALL
+        livenessProbe:
+          tcpSocket:
+            port: 8443 # Same secrure port
+          initialDelaySeconds: 3
+          periodSeconds: 3
+        readinessProbe:
+          tcpSocket:
+            port: 8443 # Same secure port
+          initialDelaySeconds: 3
+          periodSeconds: 3
+        volumeMounts:
+        - mountPath: /tmp
+          name: tmp
+          subPath: tmp
+        - mountPath: /var/run
+          name: tmp
+          subPath: run
+        - mountPath: /tls
+          name: tls
       volumes:
       - name: tmp
         emptyDir:
           medium: Memory
           sizeLimit: 64Mi
+      - name: tls
+        secret:
+          secretName: myapp-tls # name of the TLS
```

## Change the Service to point to the secure port

Lastly, you need to change the service object to point from the insecure port to the secure
port of the deployment.
