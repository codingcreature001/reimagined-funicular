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
