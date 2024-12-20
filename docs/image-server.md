# Deploy image Server

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
