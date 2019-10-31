# tpcds-mysql
This project consists of
 to run TPC-DS benchmark on MySQL. It includes all the changes on the templates for the MySQL dialect and a script to run the pipeline automatically hopefully on the cloud, like GCP's [Compute Engine](https://cloud.google.com/compute/). It uses the toolkit version 2.10.0 from [gregrahn's repository](https://github.com/gregrahn/tpcds-kit) since it includes MACOS as target for the building.

## How to run
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

 ### full outer join
 https://github.com/FdeFabricio/tpcds-mysql/commit/0b13e8d16db11996292a28bb44b82a18029756a4?diff=unified#diff-172b9509a3d7a434849f42c207ae93c4R72-R84
