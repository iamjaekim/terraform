#!/bin/bash

yum install nginx -y

rm /usr/share/nginx/html/index.html -f 
touch /usr/share/nginx/html/index.html

cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<body>

<h2>Internal</h2>
<h2>Deployed via Terraform</h2>
<p id="demo"></p>

<script>
document.getElementById("demo").innerHTML = 
"Page hostname is: " + window.location.hostname;
</script>

</body>
</html>

EOF

service nginx start