# call_wordpress_web_export
Hack, to call wordpress, $wp_version = '4.8.1' web export, via curl, to save export file.

## Background
GoDaddy hosting as of 6/3/2024 uses WP-CLI 2.8.1

wp-cli is a command line utility available to maintain Wordpress.
  https://developer.wordpress.org/cli/commands/export/
The command to export all content (except media uploads)
  wp export
and then call
  wp import [file created above] --authors=create
to copy data to new site

Note: images and video uploaded, are put in wp-content folder, and are not exported.
You need to find a way to pack these files yourself.  I use
  tar czf ~/wordpress.tar.gz


## Problem being solved:
I cannot import Wordpress's WXR XML files exported from
  WP-CLI 2.8.1 export from $wp_version = '4.8.1' 
into 
  WP-CLI 2.10.0 import into $wp_version = '6.5.3';

This project is for people who have same problem.  It is a hack, to
directly call $wp_version = '4.8.1' export link, to get a export file
that can be imported using the latest versions of the WP-CLI and wordpress
php files.  Which at time at this creation was WP-CLI 2.10.0, $wp_version = '6.5.3';

If you get the error below, importing the WXR XML file created by wp-cli, into wordpress:

oot@4375bc436bf7:/var/www/html# wp import /tmp/tictawfcom.wordpress.2024-06-03.xml --authors=create --allow-root
Starting the import process...
[03-Jun-2024 14:23:53 UTC] PHP Warning:  Undefined array key 1 in /var/www/html/wp-content/plugins/wordpress-importer/parsers/class-wxr-parser-regex.php on line 65
Warning: Undefined array key 1 in /var/www/html/wp-content/plugins/wordpress-importer/parsers/class-wxr-parser-regex.php on line 65
[03-Jun-2024 14:23:53 UTC] PHP Warning:  Undefined array key 1 in /var/www/html/wp-content/plugins/wordpress-importer/parsers/class-wxr-parser-regex.php on line 65
Warning: Undefined array key 1 in /var/www/html/wp-content/plugins/wordpress-importer/parsers/class-wxr-parser-regex.php on line 65
Error: Cannot create a user with an empty login name.

Then try getting the export from the web UI, via Tools > Export.  And if that export file can be
imported using wp-cli, then you can use this script to automate your export process:

  get_wordpress_export_from_web.sh [wordpress url do not end in /] [wordpress_user_who_can_export]

you just also need a file named "[same wordpress_user_who_can_export].txt" with the password of this user, in plaintext.
curl WILL NOT send the password in plaintext.  It will be encrypted via SSL, as any browser will,
logging into wordpress.  But the script needs to password in plaintext, to put in a form variable.

---------------
Notes:

WP-CLI 2.10.0 export from $wp_version = '6.5.3', WP-CLI 2.10.0 can import back into $wp_version = '6.5.3'

wp-cli 2.10 and 2.8 export DOES NOT wrap some fields in a CDATA, like below

   <wp:author_login><![CDATA[me@gmail.com]]></wp:author_login>
   <wp:author_email><![CDATA[me@gmail.com]]></wp:author_email>

but exports it like

  <wp:author_login>me</wp:author_login>
  <wp:author_email>me@gmail.com</wp:author_email>

This might not be the problem, since 2.10 can import, the same file it exported.  And it does the same thing

