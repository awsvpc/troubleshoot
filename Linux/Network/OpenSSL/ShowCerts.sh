openssl s_client -showcerts -partial_chain -connect http://website.com:443 < /dev/null
openssl s_client -showcerts -servername servername -connect servername:port
