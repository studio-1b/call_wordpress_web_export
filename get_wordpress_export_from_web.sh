#/bin/bash

WP_USERNAME=$1
if [ "$WP_USERNAME" == "" ]; then
  echo "USAGE: get_wordpress_export_from_web.sh [wordpress username]"
  exit 1
fi
if [ ! -f "$WP_USERNAME.txt" ]; then
  echo "USAGE: get_wordpress_export_from_web.sh [wordpress username]"
  echo "       [wordpress username].txt must exist"
  echo "                                and it contains password"
  exit 2
fi
WP_PASSWORD=$(<$WP_USERNAME.txt)



#* About to connect() to www.tictawf.com port 443 (#0)
#*   Trying 107.180.58.68... connected
#* Connected to www.tictawf.com (107.180.58.68) port 443 (#0)
#* Initializing NSS with certpath: sql:/etc/pki/nssdb
#*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
#  CApath: none
#* SSL connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
#* Server certificate:
#*       subject: CN=tictawf.com
#*       start date: Apr 11 11:07:59 2024 GMT
#*       expire date: May 13 11:07:59 2025 GMT
#*       common name: tictawf.com
#*       issuer: CN=Go Daddy Secure Certificate Authority - G2,OU=http://certs.godaddy.com/repository/,O="GoDaddy.com, Inc.",L=Scottsdale,ST=Arizona,C=US
#> POST /blog/wp-login.php HTTP/1.1
#> User-Agent: curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.44 zlib/1.2.3 libidn/1.18 libssh2/1.4.2
#> Host: www.tictawf.com
#> Accept: */*
#> Cookie: wordpress_test_cookie=WP+Cookie+check
#> Content-Type: application/x-www-form-urlencoded
#> Content-Length: 137
#>
#< HTTP/1.1 302 Found
#< Date: Mon, 03 Jun 2024 02:17:05 GMT
#< Server: Apache
#< X-Powered-By: PHP/7.3.33
#< Expires: Wed, 11 Jan 1984 05:00:00 GMT
#< Cache-Control: no-cache, must-revalidate, max-age=0
#< X-Frame-Options: SAMEORIGIN
#< Set-Cookie: wordpress_test_cookie=WP+Cookie+check; path=/blog/; secure
#< Set-Cookie: wordpress_sec_de8dbb9b8b98b7d006262ee5af2cb904=export_user%7C1717553825%7C6Xb3DxDxJUsrs63v3nzBJ216vMAKWu4SbI5gLS8u7mZ%7Ca8345a7e0c341369bec0e4e56081d5f17f5117172afe826a21ccd382b1fa4d46; path=/blog/wp-content/plugins; secure; HttpOnly
#< Set-Cookie: wordpress_sec_de8dbb9b8b98b7d006262ee5af2cb904=export_user%7C1717553825%7C6Xb3DxDxJUsrs63v3nzBJ216vMAKWu4SbI5gLS8u7mZ%7Ca8345a7e0c341369bec0e4e56081d5f17f5117172afe826a21ccd382b1fa4d46; path=/blog/wp-admin; secure; HttpOnly
#< Set-Cookie: wordpress_logged_in_de8dbb9b8b98b7d006262ee5af2cb904=export_user%7C1717553825%7C6Xb3DxDxJUsrs63v3nzBJ216vMAKWu4SbI5gLS8u7mZ%7C177e8bb0b9db83dafd861f6aa77fa7b4912f573cf353e66bd6df353e79b87c3a; path=/blog/; HttpOnly
#< Upgrade: h2,h2c
#< Connection: Upgrade
#< Location: https://www.tictawf.com/blog/wp-admin/
#< Vary: Accept-Encoding
#< Content-Length: 0
#< Content-Type: text/html; charset=UTF-8
#<
#* Connection #0 to host www.tictawf.com left intact
#* Closing connection #0

curl -v -X POST https://www.tictawf.com/blog/wp-login.php -H "Content-Type: application/x-www-form-urlencoded" -d "log=$WP_USERNAME&pwd=$WP_PASSWORD&wp-submit=Log+In&redirect_to=https%3A%2F%2Fwww.tictawf.com%2Fblog%2Fwp-admin%2F&testcookie=1"  --cookie "wordpress_test_cookie=WP+Cookie+check" &> ~/get_wordpress_export_from_web.tmp
grep '< Location: https://www.tictawf.com/blog/wp-admin/' get_wordpress_export_from_web.tmp > /dev/null
if [ $? -ne 0 ]; then
  echo "Error!  Login to wordpress website failed"
  echo "see get_wordpress_export_from_web.tmp for details"
  echo "did you supply the correct username, and have a file with same name, with password inside?"
  exit 3
fi

grep '< Set-Cookie: ' get_wordpress_export_from_web.tmp > /dev/null
if [ $? -ne 0 ]; then
  echo "Error! Cannot find login cookie"
  echo "see get_wordpress_export_from_web.tmp for details"
  echo "should have: set-cookie"
  exit 4
fi

WP_COOKIE=$(grep '< Set-Cookie: ' get_wordpress_export_from_web.tmp | cut -d';' -f1 | cut -c15- | tr '\n' ';')
curl -v 'https://www.tictawf.com/blog/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&fl-builder-template-export-select=all&submit=Download+Export+File' --cookie "$WP_COOKIE" -o wordpress.$WP_USERNAME.xml 2>&1 | grep '< Content-Disposition: attachment; filename='
if [ $? -ne 0 ]; then
  echo "ERROR!  the download reported error.  Please look at above output for clues"
  exit 5
fi
if [ ! -f "wordpress.$WP_USERNAME.xml" ]; then
  echo "ERROR!  cannot find export file"
  exit 6
fi

echo "export file is: wordpress.$WP_USERNAME.xml"
