# Traffic routing lab

The runnable traffic-routing lab in this repository uses NGINX Gateway Fabric with the Gateway API. Follow the [Gateway API lab](../lessons/gateway-api/README.md) to create a `Gateway` and an `HTTPRoute`, send HTTP and HTTPS requests, and clean up.

## Kubernetes Ingress API

Ingress remains a CKA study topic. An Ingress resource needs a controller that implements the Ingress API. NGINX Gateway Fabric manages Gateway API resources; it does not process `Ingress` resources. The examples in the study notes explain the Ingress API without installing a second controller.
