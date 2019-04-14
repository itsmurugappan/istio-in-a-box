# Run Istio on Openshift in a Container using Weave Footloose

This is an experiment to run Istio in container and test its features.

### Footloose

Footloose creates containers like VM. More details [here](https://github.com/weaveworks/footloose)

## Getting Started

#### 1. Install footloose

* Change resource available to docker to 8gb
*  Please follow the steps in this [repo](https://github.com/weaveworks/footloose)

#### 2. Clone this repo

```jshell
cd istio-in-a-box
```

check the source path in footloose.yaml. Make sure the path is Docker daemon accessible.

#### 3. Start the container, ssh and install openshift and istio

```jshell
footloose create

footloose ssh root@os0

sh /tmp/files/install.sh

export PATH=$PATH:`pwd`/openshift
```

#### 4. Run the Istio book example

```jshell

# check if the istio control plane is up

oc get pods -n istio-system

oc adm policy add-scc-to-user anyuid -z default -n myproject
oc adm policy add-scc-to-user privileged -z default -n myproject

oc apply -n myproject -f https://raw.githubusercontent.com/Maistra/bookinfo/master/bookinfo.yaml

oc apply -n myproject -f https://raw.githubusercontent.com/Maistra/bookinfo/master/bookinfo-gateway.yaml

```
#### 5. Openshift console

* https://127.0.0.1:8443
* Login creds : developer/test

#### 6. Alter host file

Edit your host file to update the localhost line

```
127.0.0.1 localhost prometheus-svc.ose kiali-svc.ose ingressgateway-svc.ose jaeger-query-svc.ose grafana-svc.ose
```

#### 7. Change the openshift routes

* Delete the routes created for ingressgateway and other apps.
* Create the route with respective host name like "ingressgateway-svc.ose" for ingressgateway

#### 8. Check out the app

* Open firefox browser and hit ingressgateway-svc.ose/productpage end point, you should see the bookstore app.

#### 9. Clean up

```
footloose delete
```

###### References

1. https://blog.alexellis.io/openshift-in-a-footloose-container/
2. https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html


