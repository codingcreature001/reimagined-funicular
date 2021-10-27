##### Notes / important threads
#

interesting thread w istio-support on privileges in grafana/jaeger UI; commands shared, specifically `oc policy` and `oc auth`. ive not used those commands w any regularity and they are not necessarily restricted to OSSM: RBAC roles restricting users to view-only access in OSSM jaeger/grafana UIs (tkt#**02750453**)

- **Question**: do we have any documentation or guidance in creating roles for view-only access to the above? my guess is that it follows vanilla k8s, but in particular, what are the cluster resources involved? the RBAC verbs, im supposing to be used are *list/watch/get*.

- **Answer**: Yes, it follows k8s directly.  Grafana, Kiali, and Jaeger all delegate through ouath proxy. The simplest is probably to give users "view" permissions on a project.  This can be done by the project admin (i.e. doesn't have to be cluster admin).  I think the command is:

`oc policy add-role-to-user -n myproject joeuser view`

but you should probably verify.

That does not sound correct.  I would use `oc policy who-can` ... to verify what the user can do.  What do you mean by "admin" access, as neither of those applications allow modification of any installed applications or the control plane.
#
- **Question**: Please find the grafana screen shot which i logged in with User(mani) has only view in istio-system(controlplane.). This is what i meant in grafana UI, user was getting admin(role) access after we add the user as view in istio-system namespace. On Namespace User only has view access.

```
[quicklab@upi-0 ~]$  oc auth can-i get pods -n istio-system --as=mani
yes
[quicklab@upi-0 ~]$  oc auth can-i edit pods -n istio-system --as=mani
no
[quicklab@upi-0 ~]$  oc auth can-i edit route -n istio-system --as=mani
no
[quicklab@upi-0 ~]$  oc auth can-i get route -n istio-system --as=mani
yes
```

- **Answer**: This is something that should probably be fixed.  That said, all users are "admin" in grafana, which I think just means they can add dashboards, etc.  Please create a JIRA.  (I noticed that the default openshift grafana doesn't allow the user to do anything, even cluster-admin, so that could serve as an example for how to lock this down.)
