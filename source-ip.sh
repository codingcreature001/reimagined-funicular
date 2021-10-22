If the X-Forwarded-For is enabled on the load balancer properly and the IP is pushed from the LB to the API server, the API server should keep the sourceIP as it is on the node. For now, it seems like the only solution is to use an LB that preserves the source address (see "Diagnostic Steps" section below).

There is a way to verify if the X-Forwarded-For headers are hitting the API (note: this does not pass through the load balancer). Invoke the API server via curl, adding an X-Forwarded-For header (making sure it is from the bastion host):

``` bash
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
TOKEN=$(kubectl get secret $(kubectl get serviceaccount default -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode )
curl $APISERVER/api/v1/namespaces/default/services \
  --header "Authorization: Bearer $TOKEN" \
  --header "X-Forwarded-For: 7.7.7.7" \
  --insecure
```

---

Here we can see the IP in the audit log (the header was kept and reported):

```
{
  "kind": "Event",
  "apiVersion": "audit.k8s.io/v1",
  "level": "Metadata",
  "auditID": "49dbb069-3d15-4617-9c71-0cfd2117f9e4",
  "stage": "ResponseComplete",
  "requestURI": "/api/v1/namespaces/default/services",
  "verb": "list",
  "user": {
    "username": "system:serviceaccount:default:default",
    "uid": "f1b737d6-d048-493a-a5ef-3b890a363d27",
    "groups": [
      "system:serviceaccounts",
      "system:serviceaccounts:default",
      "system:authenticated"
    ]
  },
  "sourceIPs": [
    "7.7.7.7",
    "10.0.59.7"
  ],
  "userAgent": "curl/7.71.1",
  "objectRef": {
    "resource": "services",
    "namespace": "default",
    "apiVersion": "v1"
  },
  "responseStatus": {
    "metadata": {},
    "status": "Failure",
    "reason": "Forbidden",
    "code": 403
  },
  "requestReceivedTimestamp": "2021-03-11T15:51:32.895180Z",
  "stageTimestamp": "2021-03-11T15:51:32.895970Z",
  "annotations": {
    "authentication.k8s.io/legacy-token": "system:serviceaccount:default:default",
    "authorization.k8s.io/decision": "forbid",
    "authorization.k8s.io/reason": ""
  }
}
```