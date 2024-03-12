#/bin/bash
# Change the filepath of openml.file 
# from "https://www.openml.org/data/download/1666876/phpFsFYVN"
# to "http://minio:9000/datasets/0000/0001/phpFsFYVN"
mysql -hdatabase -uroot -pok -e 'UPDATE openml.file SET filepath = CONCAT("http://minio:9000/datasets/0000/", LPAD(id, 4, "0"), "/", SUBSTRING_INDEX(filepath, "/", -1));'

# Update openml.expdb.dataset with the same url
mysql -hdatabase -uroot -pok -e 'UPDATE openml_expdb.dataset DS, openml.file FL SET DS.url = FL.filepath WHERE DS.did = FL.id;'