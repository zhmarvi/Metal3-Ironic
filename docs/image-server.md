# Deploy image Server
In order for ironic to provision baremetal nodes, we will need either an public accessible repo or an internal based repo accessible by the Metal3 provider in order to push and install the raw image to the BareMetal machine. Below is an example manifest we used for our Demo but this can be done completely different method. Please note any images uploaded to a server will need a file to include the sha256sum hash within a separately called file '<PATH/SHA256SUMS>'

Upstream Metal3 Documentation: https://book.metal3.io/quick-start#image-server

EXAMPLE MANIFEST

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name:  image-server
  labels:
    app:  image-server
spec:
  selector:
    matchLabels:
      app: image-server
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app:  image-server
    spec:
      # initContainers:
        # Init containers are exactly like regular containers, except:
          # - Init containers always run to completion.
          # - Each init container must complete successfully before the next one starts.
      containers:
      - name:  image-server
        image: nginx:1.27.2-alpine
        resources:
          requests:
            cpu: 1000m
            memory: 10Mi
        ports:
        - containerPort:  80
          name:  image-server
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: data-claim
      restartPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: image-server
spec:
  selector:
    app: image-server
  type: LoadBalancer
  sessionAffinity: None
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  ports:
  - name: image-server
    protocol: TCP
    port: 8080
    targetPort: 80

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-claim
  labels:
    app: data-claim
spec:
  storageClassName: "<STORAGE_CLASS>"
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
```
## POST INSTALL

Once provisioned you will be able to see the image server has a LoadBalancer Resource which can be CURL'd pulled from

### UPLOAD AN IMAGE from a local (using kubectl cp)
```
kubectl cp -n <namespace> <source path to image> <pod_name>:/usr/share/nginx/html/
```
