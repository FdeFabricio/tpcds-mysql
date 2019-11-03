# tpcds-mysql
This project consists of how to perform the TPC-DS benchmark on MySQL 8.0. It includes all the changes on the templates for the MySQL dialect and a script to run the pipeline locally or on the cloud such as on one instance of GCP's [Compute Engine](https://cloud.google.com/compute/). It uses the toolkit version 2.10.0 from [gregrahn's repository](https://github.com/gregrahn/tpcds-kit) since it includes MACOS as target for the building, although this repository already contains the toolkit builded for LINUX.

## How to run on GCP
1. Access Compute Engine and create a VM instance with Ubuntu 18.04 (you might need disk larger than 10 GB)
2. Connect to the instance from your terminal (I used [Cloud DSK](https://cloud.google.com/sdk/install) command `gcloud beta compute` from the connection menu)

<p align="center">
<img src="https://i.imgur.com/v8Zvssf.png" width="500">
</p>

3. Download the project and run the setup
```bash
git clone https://github.com/FdeFabricio/tpcds-mysql.git && \
cd tpcds-mysql && \
./setup.sh
```
This will install MySQL (bear in mind you must select verison 8.0 and leave the root password empty). It also setups variables for logging query execution.

<p align="center">
<img src="https://i.imgur.com/z813Iw6.png" width="500">
</p>

4. Now you can either run the tasks separatly or run the whole pipeline altogether
```bash
# scale factor of 1 GB, database name tpcds, runn all tasks in order
./script.sh 1 tpcds all
```

5. Save the output and extract the execution time of each query separately by processing the log files in `ls /var/log/mysql/query*.log`. The script also outputs the results and eventual errors in the folder `output`.

## Template changes
All the changes on the query templates can be found in [0b13e8d](0b13e8d16db11996292a28bb44b82a18029756a4). Some of the changes are:
### addition and substraction operations with date
```diff
     and inv_warehouse_sk   = w_warehouse_sk
     and inv_date_sk    = d_date_sk
-     and d_date between (cast ('[SALES_DATE]' as date) - 30 days)
-                    and (cast ('[SALES_DATE]' as date) + 30 days)
+     and d_date between date_sub(cast('[SALES_DATE]' as date), interval 30 day)
+                         and date_add(cast('[SALES_DATE]' as date), interval 30 day)
   group by w_warehouse_name, i_item_id) x
 where (case when inv_before > 0 
```

### white spaces
```diff
 from(select w_warehouse_name
            ,i_item_id
-            ,sum(case when (cast(d_date as date) < cast ('[SALES_DATE]' as date))	            
+            ,sum(case when (cast(d_date as date) < cast('[SALES_DATE]' as date))
	                  then inv_quantity_on_hand 
                      else 0 end) as inv_before                      
```

### rollup
```diff
      having sum(ws_quantity*ws_list_price) > (select average_sales from avg_sales)
) y
- group by rollup (channel, i_brand_id,i_class_id,i_category_id)
+ group by channel, i_brand_id,i_class_id,i_category_id with rollup
order by channel,i_brand_id,i_class_id,i_category_id
[_LIMITC];
```

### subquery alias
```diff
         and ss_sold_date_sk = d_date_sk
         and d_year in ([YEAR],[YEAR]+1,[YEAR]+2,[YEAR]+3) 
-        group by c_customer_sk)),
+        group by c_customer_sk) temp1),
 best_ss_customer as
 (select c_customer_sk,sum(ss_quantity*ss_sales_price) ssales
 ```

 ### concat
```diff
union all
select 'catalog channel' as channel
-         , 'catalog_page' || cp_catalog_page_id as id
+         , concat('catalog_page', ifnull(cp_catalog_page_id, '')) as id
        , sales
        , returns
 ```

## Resources
1. [TPC-DS specification](http://www.tpc.org/tpcds/)
2. [MySQL Slow Query Log Tutorial](https://www.a2hosting.com/kb/developer-corner/mysql/enabling-the-slow-query-log-in-mysql)
