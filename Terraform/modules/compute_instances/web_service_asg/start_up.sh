#! /bin/bash
sudo apt update
sudo apt -y install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
cat <<EOF > /var/www/html/index.html
<html><body><h1>Hello YOU. Yes, YOU!</h1>
<p>Poppy Cart is Now Live</p>
</body></html>
EOF