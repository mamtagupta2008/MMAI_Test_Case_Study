#### Important Notes

1. All the SQLs are using keywords as per Snowflake standards.

2. All the SQL's are written to load previous day data only. We can use incremental_strategy in DBT to define 
   load type based on required frequency. We can parameterize "current_date" to a parameter to make the process more dynamic.
   
3. "Table" materialization will be used to build the models in dbt and hence 
    no DMLs are generated for the case study and can be produced if required.
 
4. Separate SQL is provided for each question but we can combine 
   tables and corresponding ETL processes based on granularity of data, nature of the metrics, domain etc.

5. Also macro or ephemeral tables can be used to reuse the SQL/ Code

6. There are some hard coding like 30, 60 and 90 days period OR table names which can be 
   parameterized and combined with Jinja.

7. Staging table can be created in few cases (like registered - non registered users) to ensure 
   data quality and performance improvements.
   
8. Actual testing is not performed due to lack of real data and data structures. 

9. We can schedule these jobs to run using schedulers like airflow, dbt cloud etc. 
   Environment variables/ Parameters can be defined and passed while using dbt run command.

10. Different cluster key can be added based on table granularity and key for better performance.

11. Staging table can be created for raw data, if required to ensure data quality and better performance.

12. DBT Test can be used to perform tests on data model (given that DBT is used by organization).
   

##### Assumption
   All the users (both registered and non registered) will have entry in from page_impression.
   
##### Q5: User segmentation: 
   User segmentation could be done at any of the "content" attribute levels. 
   (E.g.: Content Type, Content Name, content id...)
   Similarly, multiple user segmentation categories could be setup as per reporting needs. 
   Below are a few data examples for different user segmentation categories for each content type.

![image](https://user-images.githubusercontent.com/55711347/133956629-eee178f9-d602-4fc1-8df9-0e896c99f3ea.png)

![image](https://user-images.githubusercontent.com/55711347/133956660-2fe4ca44-3ee8-45e9-8d86-376080172242.png)


##### Q6: Registered & Non-registered user grouping : 
   The query shown in Q6.sql file is only doing comparison at content level for user counts between registered 
   & non registered users. As the question is very open ended, similar comparisons can be done at ad level too. 
   Also, instead of just comparing the user counts between registered and non registered users, 
   we could drive much more useful information if we compare metrics like average dwell time between the two categories 
   or comparison by geography etc. In order to hold such comparison info, tables could be modelled in few different ways. 
   Example: 
	
![image](https://user-images.githubusercontent.com/55711347/133958428-ecb3a667-990c-416e-842f-43ea31c189cf.png)

![image](https://user-images.githubusercontent.com/55711347/133958441-44ad4c8c-2eb7-4417-9d0d-ac27b61af409.png)
	
![image](https://user-images.githubusercontent.com/55711347/133958464-55e9d08b-20ff-43c5-a977-c09a0828590e.png)


