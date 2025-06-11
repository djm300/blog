---
title: 'Kubernetes Omni'
date: 2025-06-11T16:02:46+02:00
---
echo "---
title: \"Demystifying Kubernetes Deployments: A Deep Dive into an Omni HelmRelease\"
date: 2025-06-11T17:39:45+02:00
draft: false
tags: [\"kubernetes\", \"helm\", \"fluxcd\", \"yaml\", \"devops\", \"omni\"]
---

# Demystifying Kubernetes Deployments: A Deep Dive into an Omni HelmRelease 🚀

Kubernetes YAML files can look intimidating at first glance, especially when they involve complex deployments managed by tools like Flux CD and Helm. In this post, we'll break down a real-world example: a `HelmRelease` resource used to deploy the Omni application. We'll go through the YAML file line by line, explaining what each part does and why it's configured that way. Get ready to unravel the magic behind this Kubernetes configuration! ✨

Let's dive into the YAML:

```yaml
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/bjw-s/helm-charts/main/charts/other/app-template/schemas/helmrelease-helm-v2beta2.schema.json
```
📄 This line is a comment providing a hint to YAML language servers (like the one in VSCode) about the schema for this file. It helps with validation and autocompletion, ensuring your YAML is correctly structured according to the `HelmRelease` definition from the `app-template` chart. Think of it as a helpful guide for your editor! 🗺️

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
```
📦 This specifies the API version of the Kubernetes object we are defining. `helm.toolkit.fluxcd.io/v2` tells Kubernetes (and Flux CD) that this is a resource managed by the Flux CD Helm Toolkit, using version 2 of its API.

```yaml
kind: HelmRelease
```
🏷️ This line declares the type of Kubernetes object. `HelmRelease` is a custom resource provided by Flux CD that represents a desired state for a Helm chart release. Instead of directly using `helm install` or `helm upgrade`, Flux CD manages the release based on this definition.

```yaml
metadata:
```
📝 The `metadata` section contains data that uniquely identifies the object, including its `name` and `namespace`.

```yaml
  name: &app omni
```
📛 Here we set the `name` of our HelmRelease to `omni`. The `&app` is a YAML anchor. It allows us to reference this value later in the file using `*app`, which is a neat way to avoid repetition and keep things consistent! 👍

```yaml
  namespace: omni
```
🏠 This specifies the Kubernetes `namespace` where this HelmRelease (and the resources it creates) will reside. In this case, it's the `omni` namespace.

```yaml
spec:
```
⚙️ The `spec` section defines the desired state of the `HelmRelease`. This is where we configure how Flux CD should manage the Helm chart.

```yaml
  interval: 5m
```
⏱️ This sets the `interval` at which Flux CD should reconcile this HelmRelease. Every 5 minutes, Flux will check if the actual state matches the desired state defined in this YAML and make any necessary changes (like applying updates).

```yaml
  chart:
```
📊 This section specifies which Helm `chart` should be deployed.

```yaml
    spec:
```
📜 Details about the chart itself.

```yaml
      chart: app-template
```
📦 We are using the `app-template` chart. This is a popular chart designed to simplify deploying common applications by providing a flexible template.

```yaml
      version: 3.7.3
```
🔢 This pins the `version` of the `app-template` chart we want to use. Using a specific version ensures reproducible deployments.

```yaml
      sourceRef:
```
🔗 This specifies the `source` of the Helm chart.

```yaml
        kind: HelmRepository
```
📦 The source is a `HelmRepository`.

```yaml
        name: bjw-s
```
📛 The `name` of the HelmRepository resource defined elsewhere in Flux CD. This tells Flux where to fetch the `app-template` chart from.

```yaml
        namespace: flux-system
```
🏠 The `namespace` where the `bjw-s` HelmRepository resource is located.

```yaml
  driftDetection:
```
🔍 This section configures how Flux CD detects configuration `drift` – situations where the actual state of the deployed resources deviates from the state defined in the HelmRelease.

```yaml
    mode: enabled
```
✅ We are enabling `driftDetection`. This means Flux will actively monitor the deployed resources and report or correct any deviations.

```yaml
  install:
```
⬇️ Configuration specific to the initial `install`ation of the Helm release.

```yaml
    remediation:
```
🩹 How to handle `remediation` (fixing issues) during installation.

```yaml
      retries: 3
```
🔄 If the installation fails, Flux will `retry` up to 3 times.

```yaml
  upgrade:
```
⬆️ Configuration specific to `upgrade`s of the Helm release.

```yaml
    cleanupOnFail: true
```
🧹 If an `upgrade` fails, this setting ensures that any partially applied changes are `cleanupOnFail`ed.

```yaml
    remediation:
```
🩹 How to handle `remediation` during upgrades.

```yaml
      strategy: rollback
```
⏪ The `strategy` for remediation is `rollback`. If an upgrade fails, Flux will attempt to roll back to the previous working version.

```yaml
      retries: 3
```
🔄 If the rollback fails, Flux will `retry` up to 3 times.

```yaml
  values:
```
🔧 This is the core of the application configuration! The `values` section contains overrides for the default values provided by the `app-template` Helm chart. This is where we customize the deployment for the Omni application.

```yaml
    defaultPodOptions:
```
⚙️ These are `defaultPodOptions` that will be applied to all pods created by this HelmRelease.

```yaml
      annotations:
```
📝 `annotations` are non-identifying metadata that can be attached to Kubernetes objects.

```yaml
        backup.velero.io/backup-volumes: out
```
💾 This specific annotation is used by Velero, a Kubernetes backup tool. It tells Velero to include the volume named `out` when performing backups of pods created by this release.

```yaml
      topologySpreadConstraints:
```
⚖️ `topologySpreadConstraints` help ensure that pods are evenly distributed across your cluster's topology domains (like nodes, racks, or zones) to improve availability.

```yaml
        - maxSkew: 3
```
📏 `maxSkew` defines the maximum allowed difference between the number of matching pods in any two topology domains. A skew of 3 means the difference can be at most 3.

```yaml
          topologyKey: kubernetes.io/hostname
```
🔑 The `topologyKey` specifies the node label that Kubernetes uses to identify the topology domain. `kubernetes.io/hostname` means pods will be spread across individual nodes.

```yaml
          whenUnsatisfiable: DoNotSchedule
```
🚫 `whenUnsatisfiable` determines what happens if the constraint cannot be met. `DoNotSchedule` means the pod will not be scheduled until the constraint can be satisfied.

```yaml
          labelSelector:
```
🎯 The `labelSelector` identifies the set of pods to which this constraint applies.

```yaml
            matchLabels:
```
🏷️ We are matching pods based on these `labels`.

```yaml
              app.kubernetes.io/name: *app
```
📛 This matches pods where the label `app.kubernetes.io/name` is equal to the value of the `*app` alias, which is `omni`. This ensures the spreading constraint applies specifically to the Omni application pods.

```yaml
    controllers:
```
🎮 This section defines the Kubernetes `controllers` (like Deployments, StatefulSets, etc.) that the `app-template` chart should create.

```yaml
      omni:
```
📦 We are configuring a controller named `omni`.

```yaml
        replicas: 1
```
🧍 This sets the desired number of `replicas` (instances) for the Omni application to 1.

```yaml
        type: deployment
```
🏗️ The type of controller is a standard Kubernetes `deployment`.

```yaml
        annotations:
```
📝 `annotations` for the Deployment object itself.

```yaml
          reloader.stakater.com/auto: \"true\"
```
🔄 This annotation is used by Stakater Reloader. When set to `\"true\"`, Reloader will automatically restart the Deployment's pods if any ConfigMaps or Secrets they depend on are updated. Very handy for applying configuration changes!

```yaml
          backup.velero.io/backup-volumes: out
```
💾 Another Velero annotation, similar to the one on the pod, ensuring the `out` volume is backed up.

```yaml
        containers:
```
📦 This section defines the `containers` that will run within the pods managed by this Deployment.

```yaml
          app:
```
🏃 We are defining a container named `app`.

```yaml
            image:
```
🖼️ Details about the container `image` to use.

```yaml
              repository: ghcr.io/siderolabs/omni
```
📍 The `repository` where the container image is stored (GitHub Container Registry in this case).

```yaml
              tag: v0.50.1
```
🏷️ The specific `tag` (version) of the Omni image to pull.

```yaml
            args:
```
⚙️ These are the command-line `arguments` passed to the Omni container's entrypoint. These configure the Omni application's behavior.

```yaml
              - --account-id=730ca302-bbcc-4002-b7f3-8e31885bc538
```
🆔 Sets the Omni `--account-id`.

```yaml
              - --name=onprem-omni
```
📛 Sets the `--name` for this Omni instance.

```yaml
# EXTERNAL ETCD
#              - --etcd-embedded=false
#              - --etcd-ca-path=/cert/ca.crt
#              - --etcd-client-cert-path=/cert/tls.crt
#              - --etcd-client-key-path=/cert/tls.key
#              - --etcd-endpoints=[omni-etcd-headless.omni.svc.cluster.local:2379]
# STOP EXTERNAL ETCD
```
📝 These lines are commented out (`#`). They show how you would configure Omni to use an `EXTERNAL ETCD` cluster instead of an embedded one, specifying paths for certificates and etcd endpoints.

```yaml
#              - --cert=/cert/tls.crt
#              - --key=/cert/tls.key
#              - --machine-api-cert=/cert/tls.crt
#              - --machine-api-key=/cert/tls.key
```
🔒 More commented out arguments related to specifying certificate and key paths for various Omni components.

```yaml
              - --private-key-source=file:///secrets/omni.asc
```
🔑 Specifies the `--private-key-source` for Omni, pointing to a file within the container's `/secrets` directory.

```yaml
              - --event-sink-port=8091
```
👂 Sets the `--event-sink-port` to 8091.

```yaml
              - --log-server-port=8092
```
📜 Sets the `--log-server-port` to 8092.

```yaml
              - --bind-addr=0.0.0.0:80
```
🌐 Sets the main API `--bind-addr` to listen on all network interfaces (`0.0.0.0`) on port 80.

```yaml
              - --advertised-api-url=https://omni.cluster2.doublepulsar.win/
```
📢 Sets the `--advertised-api-url` for the main API, the URL clients should use to reach it.

```yaml
# Fails otherwise
              - --machine-api-bind-addr=0.0.0.0:8200
```
🤖 Sets the `--machine-api-bind-addr` to listen on all interfaces on port 8200. The comment `# Fails otherwise` suggests this might be necessary for the application to function correctly in this environment.

```yaml
              - --siderolink-api-advertised-url=https://omni-api.cluster2.doublepulsar.win:443
```
🔗 Sets the `--siderolink-api-advertised-url`, the URL for the Siderolink API.

```yaml
#PROXY
              - --k8s-proxy-bind-addr=0.0.0.0:8100
```
🌐 Sets the `--k8s-proxy-bind-addr` for the Kubernetes proxy to listen on all interfaces on port 8100.

```yaml
              - --advertised-kubernetes-proxy-url=https://omni-proxy.cluster2.doublepulsar.win/
```
📢 Sets the `--advertised-kubernetes-proxy-url` for the Kubernetes proxy.

```yaml
#WEB
#SIDEROLINK BIND ADDRESSES ARE DEPRECATED, USE MIACHINELINK (https://github.com/siderolabs/omni/blob/c9b8b3f6ccaa2f638ab9d1a63dc0b3aa9c3d8790/cmd/omni/main.go#L320)
# UUse grpc tunnel to wrap wireguard traffic instead of UDP
              - --siderolink-use-grpc-tunnel=true
```
Tunneling WireGuard traffic over gRPC.

```yaml
#              - --siderolink-wireguard-advertised-addr=192.168.50.51:30007
```
Commented out WireGuard advertised address.

```yaml
#AUTH
              - --initial-users=joris@ligoro.be
```
👤 Sets the `--initial-users` for authentication.

```yaml
              - --auth-saml-enabled=true
```
🔑 Enables SAML authentication.

```yaml
              - --auth-saml-url=https://login.microsoftonline.com/722e84ad-afd7-47d4-802e-b346f71babe3/federationmetadata/2007-06/federationmetadata.xml?appid=718c1db0-c155-4dd0-94b8-00bfcab8ffe5
```
🔗 Provides the `--auth-saml-url`, the metadata URL for the SAML identity provider (looks like Azure AD).

```yaml
              - --enable-break-glass-configs
```
🚨 Enables `--enable-break-glass-configs`, likely providing emergency access mechanisms.

```yaml
              - --audit-log-dir=/audit/audit-log
```
📜 Sets the `--audit-log-dir` where audit logs will be stored within the container.

            env:
```
🌍 Environment variables for the container.

```yaml
              TZ: Europe/Brussels
```
⏰ Sets the `TZ` (timezone) environment variable.

```yaml
            probes:
```
🩺 `probes` are used by Kubernetes to check the health of the container.

```yaml
              liveness: &probes
```
❤️ The `liveness` probe checks if the container is running. If it fails, Kubernetes will restart the container. `&probes` is a YAML anchor for reuse.

```yaml
                enabled: true
```
✅ Enable the liveness probe.

```yaml
                custom: true
```
🔧 Use a `custom` probe configuration.

```yaml
                spec:
```
📜 The probe `spec`ification.

```yaml
                  httpGet:
```
🌐 Use an `httpGet` probe, which sends an HTTP request to the container.

```yaml
                    path: /healthz
```
🛣️ The `path` to request for the health check.

```yaml
                    port: 80
```
🚪 The `port` to send the request to.

```yaml
                  initialDelaySeconds: 60
```
⏳ Wait for `initialDelaySeconds` (60 seconds) before starting the first probe. This gives the application time to start up.

```yaml
                  periodSeconds: 10
```
⏱️ Perform the probe every `periodSeconds` (10 seconds).

```yaml
#                  timeoutSeconds: 5
```
Commented out `timeoutSeconds`.

```yaml
                  failureThreshold: 10
```
❌ If the probe fails `failureThreshold` (10) times in a row, Kubernetes considers the container unhealthy.

```yaml
              readiness: *probes
```
✅ The `readiness` probe checks if the container is ready to serve traffic. If it fails, Kubernetes will stop sending traffic to the pod. `*probes` references the configuration defined for the liveness probe using the alias.

```yaml
            resources:
```
💪 `resources` define the CPU and memory requests and limits for the container. This helps Kubernetes schedule pods efficiently and prevents containers from consuming excessive resources.

```yaml
              limits:
```
📈 `limits` are the maximum amount of resources the container is allowed to use.

```yaml
                cpu: 1000m
```
🧠 CPU `limit` is 1000 millicores, which is equivalent to 1 full CPU core.

```yaml
                memory: 800Mi
```
💾 Memory `limit` is 800 MiB.

```yaml
              requests:
```
📉 `requests` are the minimum amount of resources the container is guaranteed to get.

```yaml
                cpu: 200m
```
🧠 CPU `request` is 200 millicores (0.2 CPU cores).

```yaml
                memory: 128Mi
```
💾 Memory `request` is 128 MiB.

            securityContext:
```
🔒 `securityContext` defines privilege and access control settings for the container.

```yaml
              allowPrivilegeEscalation: false
```
🛡️ `allowPrivilegeEscalation: false` prevents the container from gaining more privileges than its parent process.

```yaml
              capabilities:
```
🔑 Linux `capabilities` grant specific privileges without giving full root access.

```yaml
                add:
```
➕ `add` specifies capabilities to add to the default set.

```yaml
                  - NET_ADMIN
```
🌐 Adding `NET_ADMIN` capability, which is often needed for network-related operations like configuring network interfaces (e.g., for WireGuard).

```yaml
              readOnlyRootFilesystem: true
```
📁 `readOnlyRootFilesystem: true` mounts the container's root filesystem as read-only, enhancing security by preventing the application from writing to arbitrary locations.

    service:
```
🚪 This section defines Kubernetes `Service`s, which provide a stable network endpoint to access the application's pods.

```yaml
      app:
```
🌐 Defines a Service named `app`.

```yaml
        controller: omni
```
🔗 This Service targets pods managed by the `omni` controller.

```yaml
        annotations:
```
📝 Annotations for the Service.

```yaml
          traefik.ingress.kubernetes.io/service.serversscheme: h2c
```
🚦 This Traefik annotation specifies that the backend service (`app`) uses HTTP/2 Cleartext (`h2c`).

```yaml
        ports:
```
🚪 Port mappings for the Service.

```yaml
          http:
```
🌐 Defines a port named `http`.

```yaml
            port: 80
```
🚪 The Service will expose port 80, routing traffic to the container's port 80.

      api:
```
🌐 Defines a Service named `api` for the Omni API.

```yaml
        controller: omni
```
🔗 Targets the `omni` controller.

```yaml
        primary: false
```
This indicates it's not the primary service for the application.

```yaml
        annotations:
```
📝 Annotations for the API Service.

```yaml
          traefik.ingress.kubernetes.io/service.serversscheme: h2c
```
🚦 Traefik annotation for HTTP/2 Cleartext.

```yaml
        ports:
```
🚪 Port mappings.

```yaml
          http:
```
🌐 Defines a port named `http`.

```yaml
            port: 8200
```
🚪 The Service exposes port 8200, routing traffic to the container's port 8200 (the Machine API port).

      k8s-proxy:
```
🌐 Defines a Service named `k8s-proxy` for the Kubernetes proxy.

```yaml
        controller: omni
```
🔗 Targets the `omni` controller.

```yaml
        primary: false
```
Not the primary service.

```yaml
        ports:
```
🚪 Port mappings.

```yaml
          http:
```
🌐 Defines a port named `http`.

```yaml
            port: 8100
```
🚪 The Service exposes port 8100, routing traffic to the container's port 8100 (the Kubernetes proxy port).

      wireguard:
```
🌐 Defines a Service named `wireguard` for WireGuard traffic.

```yaml
        controller: omni
```
🔗 Targets the `omni` controller.

```yaml
        primary: false
```
Not the primary service.

```yaml
        type: NodePort
```
🚪 The `type` is `NodePort`. This makes the Service accessible on a static port on each node in the cluster, in addition to the cluster IP.

```yaml
        ports:
```
🚪 Port mappings.

```yaml
          wireguard:
```
🌐 Defines a port named `wireguard`.

```yaml
            port: 50180
```
🚪 The Service exposes port 50180, routing traffic to the container's port 50180.

```yaml
            protocol: UDP
```
UDP `protocol` is specified, common for WireGuard.

```yaml
            nodePort: 30007
```
🚪 The static port exposed on each node is `nodePort` 30007.

    ingress:
```
➡️ This section defines Kubernetes `Ingress` resources, which manage external access to the Services in the cluster, typically providing HTTP and HTTPS routing.

```yaml
      omni:
```
🌐 Defines an Ingress named `omni` for the main application.

```yaml
        enabled: true
```
✅ Enable this Ingress.

```yaml
        annotations:
```
📝 Annotations for the Ingress.

```yaml
          cert-manager.io/cluster-issuer: letsencrypt-prod
```
🔒 This annotation is used by cert-manager to automatically provision a TLS certificate for this Ingress using the `letsencrypt-prod` ClusterIssuer.

```yaml
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
```
🚦 This Traefik annotation specifies that this Ingress should use the `websecure` entrypoint, which is typically configured for HTTPS traffic.

```yaml
          traefik.ingress.kubernetes.io/router.tls: \"true\"
```
🔒 This Traefik annotation explicitly enables TLS for this router.

        hosts:
```
🌐 Defines the `hosts` (domain names) that this Ingress will handle traffic for.

```yaml
          - host: \"omni.cluster2.doublepulsar.win\"
```
🌍 The specific `host`name this Ingress rule applies to.

            paths:
```
🛣️ Defines the URL `paths` under the host that this rule applies to.

```yaml
              - path: /
```
➡️ This rule applies to the root `path` (`/`).

                service:
```
🔗 Specifies the `service` to which traffic matching this path should be routed.

                  identifier: app
```
📛 References the `app` Service defined earlier in the `service` section.

        tls:
```
🔒 TLS configuration for this Ingress.

          - secretName: omni-tls
```
🔑 Specifies the `secretName` where the TLS certificate and key will be stored. cert-manager will populate this secret.

            hosts:
```
🌍 The `hosts` that this TLS secret is valid for.

```yaml
              - \"omni.cluster2.doublepulsar.win\"
```
The hostname.

      api:
```
🌐 Defines an Ingress named `api` for the Omni API.

```yaml
        enabled: true
```
✅ Enable this Ingress.

        annotations:
```
📝 Annotations for the API Ingress.

```yaml
          cert-manager.io/cluster-issuer: letsencrypt-prod
```
🔒 cert-manager issuer.

          traefik.ingress.kubernetes.io/router.entrypoints: websecure
```
🚦 Traefik entrypoint.

```yaml
          traefik.ingress.kubernetes.io/router.tls: \"true\"
```
🔒 Traefik TLS.

        hosts:
```
🌐 Host rules.

          - host: \"omni-api.cluster2.doublepulsar.win\"
```
🌍 The hostname for the API.

            paths:
```
🛣️ Path rules.

              - path: /
```
➡️ Root path.

                service:
```
🔗 Service to route to.

                  identifier: api
```
📛 References the `api` Service.

        tls:
```
🔒 TLS configuration.

          - secretName: omni-api-tls
```
🔑 Secret for TLS.

            hosts:
```
🌍 Hosts covered by TLS.

```yaml
              - \"omni-api.cluster2.doublepulsar.win\"
```
The hostname.

      proxy:
```
🌐 Defines an Ingress named `proxy` for the Kubernetes proxy.

```yaml
        enabled: true
```
✅ Enable this Ingress.

        annotations:
```
📝 Annotations for the Proxy Ingress.

```yaml
          cert-manager.io/cluster-issuer: letsencrypt-prod
```
🔒 cert-manager issuer.

          traefik.ingress.kubernetes.io/router.entrypoints: websecure
```
🚦 Traefik entrypoint.

          traefik.ingress.kubernetes.io/router.tls: \"true\"
```
🔒 Traefik TLS.

        hosts:
```
🌐 Host rules.

          - host: \"omni-proxy.cluster2.doublepulsar.win\"
```
🌍 The hostname for the proxy.

            paths:
```
🛣️ Path rules.

              - path: /
```
➡️ Root path.

                service:
```
🔗 Service to route to.

                  identifier: k8s-proxy
```
📛 References the `k8s-proxy` Service.

        tls:
```
🔒 TLS configuration.

          - secretName: omni-proxy-tls
```
🔑 Secret for TLS.

            hosts:
```
🌍 Hosts covered by TLS.

              - \"omni-proxy.cluster2.doublepulsar.win\"
```
The hostname.

    serviceAccount:
```
👤 This section configures the Kubernetes `ServiceAccount` for the application pods.

```yaml
      create: true
```
✅ `create: true` tells the chart to create a new ServiceAccount.

```yaml
      name: omni
```
📛 The `name` of the ServiceAccount will be `omni`.

    persistence:
```
💾 This section defines `persistence` configurations, primarily for volumes mounted into the pods.

```yaml
      net-tun:
```
📁 Defines a volume named `net-tun`.

```yaml
        type: hostPath
```
🏠 The `type` is `hostPath`, meaning it mounts a file or directory from the host node's filesystem into the pod.

```yaml
        hostPath: /dev/net/tun
```
📍 The specific `hostPath` to mount. `/dev/net/tun` is a device file often needed for network tunneling interfaces like WireGuard.

```yaml
      out:
```
📁 Defines a volume named `out`.

```yaml
        type: persistentVolumeClaim
```
💾 The `type` is `persistentVolumeClaim` (PVC), which requests persistent storage from the cluster.

```yaml
        storageClass: openebs-hostpath
```
📦 Specifies the `storageClass` to use for provisioning the PVC. `openebs-hostpath` suggests using OpenEBS with the hostpath provisioner.

```yaml
        accessMode: ReadWriteOnce
```
🔒 The `accessMode` is `ReadWriteOnce`, meaning the volume can be mounted as read-write by a single node.

        size: 1Gi
```
📏 Requests a `size` of 1 GiB for the volume.

        globalMounts:
```
📍 `globalMounts` specifies where this volume should be mounted in the containers.

```yaml
          - path: /_out
```
📁 Mount the volume at the `/_out` path inside the container.

      audit:
```
📁 Defines a volume named `audit` for audit logs.

```yaml
        type: persistentVolumeClaim
```
💾 PVC type.

```yaml
        storageClass: openebs-hostpath
```
📦 Storage class.

        accessMode: ReadWriteOnce
```
🔒 Access mode.

        size: 1Gi
```
📏 Size.

        globalMounts:
```
📍 Mount points.

          - path: /audit
```
📁 Mount at `/audit`.

      run:
```
📁 Defines a volume named `run`.

        type: emptyDir
```
🗑️ The `type` is `emptyDir`. This volume is created when the pod is assigned to a node and exists as long as the pod is running on that node. It's initially empty.

        globalMounts:
```
📍 Mount points.

          - path: /run
```
📁 Mount at `/run`.

          - path: /var/run
```
📁 Mount at `/var/run`. These paths are often used for temporary runtime data or sockets.

      secrets:
```
📁 Defines a volume named `secrets`.

        type: secret
```
🔑 The `type` is `secret`, which makes the contents of a Kubernetes Secret available as files within the pod.

        name: omni-secrets
```
📛 The `name` of the Secret to mount.

        globalMounts:
```
📍 Mount points.

          - path: /secrets
```
📁 Mount at `/secrets`. This is where the `omni.asc` private key file referenced in the container args is expected to be found.

```yaml
#      tls-secret:
#        type: secret
#        name: etcd-client-tls
#        globalMounts:
#          - path: /cert
```
🔒 Commented out volume for mounting a TLS secret, likely related to the external etcd configuration.

```yaml
---
```
📄 Another YAML document separator.

## Conclusion 🎉

We've walked through a detailed Kubernetes `HelmRelease` YAML file used to deploy the Omni application with Flux CD and the `app-template` chart. We covered everything from basic metadata and chart specification to application-specific values, including container arguments, probes, resources, services, ingresses, service accounts, and persistence.

Understanding these configurations is key to managing applications effectively in a Kubernetes environment. This example showcases how Helm and Flux CD can be used together to define and automate complex deployments.

I hope this line-by-line breakdown helps demystify Kubernetes YAML for you! If you have any questions or want to explore other parts of this configuration, let me know! 👇