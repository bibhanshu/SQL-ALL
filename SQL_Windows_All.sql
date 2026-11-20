
SELECT * FROM Employees ORDER BY emp_id;

SELECT * FROM Sales ORDER BY sale_id;


--Ranking Functions

--The HR team wants to identify the highest-paid employee in each department.

With CTE as (Select * ,
ROW_NUMBER() Over( Partition by department Order by Salary desc ,emp_id ) as Row_num
from Employees)
select emp_name,department,salary from CTE
where Row_num = 1

-- The HR team suspects that duplicate employee records have been entered into the database.
With CTE as (select *,
ROW_NUMBER() Over (Partition by emp_id order by emp_name) as row_no
from Employees)
Select emp_id,emp_name,department,salary,
case 
When row_no = 1 Then 'Retain'
else 'Duplicate'
end as 'Record_Status'
from CTE 


--- Rank (1 1 3) Dense_rank (1 1 2)
-- HR wants to compare employee salary rankings across departments.

select * ,
Rank() Over( Partition by department Order by Salary desc) as RANK_Pay,
DENSE_Rank() Over( Partition by department Order by Salary desc) as D_RANK_Pay
from Employees

--The HR department wants to identify employees earning the third-highest distinct salary in each department
With CTE as (select *,
DENSE_Rank() Over( Partition by department Order by Salary desc) as Sal_Rank
from Employees)
select * from CTE 
where Sal_Rank = 3

--NTILE --- buckets 
--The HR team wants to divide all employees into four salary groups, based on salary from highest to lowest.
select *,
NTILE(4) OVER(
Order by salary desc
) as Pay_Group
from Employees

--- Day 2 Agg Functions :
--The HR analytics team wants to analyse employee sales performance

select E.emp_id,E.emp_name,E.department,S.sale_id,S.amount,
Sum(S.amount) OVER (Partition by E.emp_name) as Employee_Total_Sales,
AVG(S.amount) OVER (Partition by E.emp_name) as Employee_Avg_Sales
from Employees E
inner join Sales S on E.emp_id = S.emp_id

--The management team wants to analyse employee sales performance over time.

select E.emp_id,E.emp_name,E.department,S.sale_id,S.amount,
Sum(S.amount) OVER (Partition by E.emp_name) as Employee_Total_Sales,
AVG(S.amount) OVER (Partition by E.emp_name) as Employee_Avg_Sales,
Sum(S.amount) OVER (Partition by E.emp_name Order by S.sale_date ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW ) as Running_Sales,
AVG(S.amount) OVER (Partition by E.emp_name Order by S.sale_date  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as Running_Avg_Sales
from Employees E
inner join Sales S on E.emp_id = S.emp_id
       
--Write a query that returns one row per employee, showing:
--1. Employee ID and employee name.
--2. Total number of sales transactions made by that employee.
--3. Number of distinct sale dates on which the employee made sales.
--4. Number of non-NULL sales amounts.

WITH CTE AS
(
    SELECT
        E.emp_id,
        E.emp_name,

        COUNT(S.sale_id) OVER (
            PARTITION BY E.emp_id
        ) AS sales_transactions,

        DENSE_RANK() OVER (
            PARTITION BY E.emp_id
            ORDER BY S.sale_date
        ) AS Distinct_sales_date,

        COUNT(S.amount) OVER (
            PARTITION BY E.emp_id
        ) AS No_non_null_Sales

    FROM Employees E
    INNER JOIN Sales S
        ON E.emp_id = S.emp_id
)
SELECT
    emp_id,
    emp_name,
    MAX(Distinct_sales_date) AS Distinct_sales_date,
    MAX(sales_transactions) AS sales_transactions,
    MAX(No_non_null_Sales) AS No_non_null_Sales
FROM CTE
GROUP BY emp_id, emp_name;


--Using our Employees and Sales tables, write a query that returns one row per employee with:
--1. emp_id and emp_name.
--2. Total number of transactions.
--3. Number of distinct sale dates.
--4. Number of non-NULL sales amounts.
--5. The employee's total sales amount.
--6. The employee's highest single transaction amount.
--7. The employee's lowest single transaction amount.

With CTE as (
select E.emp_id,E.emp_name,S.sale_date,S.amount,
count(S.amount) over(partition by E.emp_id) as transactions_number,
sum(S.amount) over(partition by E.emp_id) as total_sales_amount
from Employees E
inner join Sales S on E.emp_id = S.emp_id)
select emp_id,emp_name,max(transactions_number) as Total_transactions_number, count(distinct sale_date) as Distinct_sales_Date,max(amount) as highest_single_transaction_amount, 
min(amount) as Min_single_transaction_amount,
count(amount) as Not_null_amount,max(total_sales_amount) as total_sales_amount
from CTE 
where amount is not null 
group by emp_id,emp_name


--Medium question — 15 marks
--Using our existing Employees table, write a SQL query displaying:
--1. Employee ID
--2. Employee name
--3. Department
--4. Salary
--5. Minimum salary in the employee's department
--6. Maximum salary in the employee's department
--7. Difference between the department's maximum and minimum salary
with CTE as (
select E.emp_id,E.emp_name,E.department,E.salary,
Min(E.salary) over(partition by E.department) as Min_pay,
Max(E.salary) over(partition by E.department) as Max_pay
from Employees E
inner join Sales S on E.emp_id = S.emp_id),
CTE2 as (
select emp_id,emp_name,department,salary,Min_pay,Max_pay,(Max_pay - Min_pay) as Diff_pay from CTE 
)
select emp_id,emp_name,department,salary,Min_pay,Max_pay,Diff_pay from CTE2
group by emp_id,emp_name,department,salary,Min_pay,Max_pay, Diff_pay


--Using Employees, calculate:
--1. Employee salary.
--2. Department minimum salary.
--3. Department maximum salary.
--4. Difference between employee salary and department minimum salary.
--5. Difference between employee salary and department maximum salary.
--6. Department average salary.
--7. Rank employees by salary within their department.
--Requirements: preserve all employee rows and use window functions.
With CTE as (
SELECT *,
Min(salary) over(Partition by department) as Min_pay,
Max(salary) over(Partition by department) as Max_pay,
Avg(salary) over(Partition by department) as Avg_pay,
Rank() over(Partition by department order by salary desc) as Salery_rank -- I dont see in ques asc or desc i assume desc 
FROM Employees)
select *,(salary - Min_pay) as Pay_diffrence_from_min ,(salary - Max_pay) as Pay_diffrence_from_max  from CTE 


--Write a SQL query to display:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise population standard deviation of salary using STDEVP().

select emp_id,emp_name,department,salary,
STDEVP(salary) Over(Partition by department) as Department_wise_population
FROM Employees

--Write a query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise population standard deviation using STDEVP().
--6. Overall population standard deviation across all employees using STDEVP().

select emp_id,emp_name,department,salary,
STDEVP(salary) Over(Partition by department) as Department_wise_population,
STDEV(salary) Over() as Overall_population_standard
FROM Employees

--You are working with our existing Employees table.
--Requirement: Write a SQL query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise population variance of salary using VARP().

select emp_id,emp_name,department,salary,
VARP(salary) Over(Partition by department) as Department_wise_population
FROM Employees

--Write a query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise sample variance using VAR().
--6. Department-wise population variance using VARP().

select emp_id,emp_name,department,salary,
VARP(salary) Over(Partition by department) as Department_wise_population,
VAR(salary) Over(Partition by department) as Department_wise_Sample
FROM Employees

--Lead Lag :(Lead Next and Lag is previous )
--Using our existing Employees and Sales tables, write a query displaying:
--1. emp_id
--2. emp_name
--3. sale_date
--4. amount
--5. Previous transaction amount using LAG().
--6. Next transaction amount using LEAD().

SELECT
    E.emp_id,
    E.emp_name,
    S.sale_date,
    S.amount,

    LAG(S.amount) OVER (
        PARTITION BY E.emp_id
        ORDER BY S.sale_date, S.sale_id
    ) AS Previous_Transaction,

    LEAD(S.amount) OVER (
        PARTITION BY E.emp_id
        ORDER BY S.sale_date, S.sale_id
    ) AS Next_Transaction

FROM Employees E
INNER JOIN Sales S
    ON E.emp_id = S.emp_id

--Using the Sales table, write a query displaying:
-- emp_id
-- sale_id
-- sale_date
-- amount
--5. Previous transaction amount using LAG().
--6. Next transaction amount using LEAD().
--7. Difference between the current transaction amount and the previous transaction amount.

With CTE as (
select E.emp_id,
    E.emp_name,
    S.sale_date,
    S.amount,
    LAG(S.amount) OVER (
        PARTITION BY E.emp_id
        ORDER BY S.sale_date, S.sale_id
    ) AS Previous_Transaction,

    LEAD(S.amount) OVER (
        PARTITION BY E.emp_id
        ORDER BY S.sale_date, S.sale_id
    ) AS Next_Transaction
    FROM Employees E
INNER JOIN Sales S
ON E.emp_id = S.emp_id)
select *,(amount - Previous_Transaction) as Difference_in from CTE 


---Day 5 
--Task: Write a SQL query to display:
--1. Employee ID
--2. Employee name
--3. Department
--4. Salary
--5. The highest salary in that employee's department, using FIRST_VALUE().
--Requirements:
--- Keep all 12 employees in the output.
--- Highest salary should appear for every employee in their respective department.
--- Use FIRST_VALUE() and PARTITION BY.



SELECT emp_id,emp_name,department,salary,FIRST_VALUE(salary) Over(partition by department order by salary desc) as Max_pay 
FROM Employees

--Using the Sales table, write a query displaying:
--1. emp_id
--2. sale_id
--3. sale_date
--4. amount
--5. The first sale amount for each employee.
--6. The first sale date for each employee.
--Requirements:
--- Keep all 30 transactions.
--- First sale means the earliest transaction chronologically.
--- Use FIRST_VALUE() for both the amount and date.
--- Make the ordering deterministic using sale_date and sale_id.

select E.emp_id,S.sale_id,S.sale_date,S.amount,
FIRST_VALUE(S.amount) Over(Partition by E.emp_id,E.emp_name order by S.sale_date) as First_sales_amount,
FIRST_VALUE(S.sale_date) Over(Partition by E.emp_id,E.emp_name order by S.sale_date) as First_sales_date
from Employees E
inner join Sales S on E.emp_id = S.emp_id


--Using our Employees table, write a query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise PERCENT_RANK() based on salary.
--Requirements:
--- Highest salary should receive 0.
--- Lowest salary should receive 1.
--- Employees with equal salaries should receive the same percentage rank.
--- Keep all 12 employees in the output.

select *,
PERCENT_RANK() Over(partition by department order by salary desc) as Salary_percentage_rank
 from Employees 


--Using the Employees table, write a query to display:
--1. Employee ID
--2. Employee name
--3. Department
--4. Salary
--5. Department-wise RANK()
--6. Department-wise PERCENT_RANK()
--Requirements:
--- Highest salary should receive rank 1.
--- Highest salary should receive percentage rank 0.
--- Employees with equal salaries should receive the same rank and percentage rank.
--- Keep all 12 employees.
--- Sort the final output by department and salary descending.
--Write your query. I'll evaluate it out of 25.

select *,
PERCENT_RANK() Over(partition by department order by salary desc) as Salary_percentage_rank,
RANK() Over(partition by department order by salary desc) as Salary_rank
from Employees
ORDER BY department, salary DESC


--Using our Employees table, write a query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise CUME_DIST() based on salary.
--Requirements:
-- Highest salary should appear first in the ordering.
-- Keep all 12 employees.
-- Employees with equal salaries should receive the same cumulative distribution value.

SELECT *,
    CUME_DIST() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS Salary_Cume_Dist
FROM Employees;


--Write a query using PERCENTILE_CONT(0.5) to calculate the department-wise median salary.
select *,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary ASC)
OVER (PARTITION BY department) as department_wise_median_salary
from Employees

--Using our existing Employees table, write a query displaying:
--1. emp_id
--2. emp_name
--3. department
--4. salary
--5. Department-wise 75th percentile salary using PERCENTILE_DISC().
--Requirements:
--- Use PERCENTILE_DISC(0.75).
-- Use WITHIN GROUP (ORDER BY salary ASC).
-- Keep all 12 employee records.
-- Calculate the percentile separately for each department.

select *,
PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY salary ASC)
OVER (PARTITION BY department) as department_wise_median_salary
from Employees

--Write a query displaying:
--1. sale_id
--2. emp_id
--3. sale_date
--4. amount
--5. Employee-wise running total.
--Requirements:
-- Calculate the running total separately for each employee.
-- Use PARTITION BY emp_id.
-- Order transactions by sale_date, sale_id.
-- Explicitly use ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

select * ,
Sum(S.amount) Over(partition by E.emp_id,E.emp_name order by S.sale_date,S.sale_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as 
Emp_Wise_running_total
from Employees E
inner join Sales S on E.emp_id = S.emp_id


--Using our Sales table, write a query displaying:
--1. sale_id
--2. emp_id
--3. sale_date
--4. amount
--5. Employee-wise running total using ROWS.
--6. Employee-wise cumulative total using RANGE.
--Requirements:
-- Partition by emp_id.
-- Order both calculations by sale_date only.
-- Use ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW for the first calculation.
-- Use RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW for the second calculation.
-- Keep all 30 transactions.
--Important: We deliberately use sale_date without sale_id here because we want to observe what happens when multiple transactions have the same ordering value.

select * ,
Sum(S.amount) Over(partition by E.emp_id,E.emp_name order by S.sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as 
Emp_Wise_running_total,
Sum(S.amount) Over(partition by E.emp_id,E.emp_name order by S.sale_date Range BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as 
Emp_Wise_cumulative_total
from Employees E
inner join Sales S on E.emp_id = S.emp_id