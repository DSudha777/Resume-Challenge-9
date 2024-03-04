Select distinct product_name from dim_products p
join fact_events e
on p.product_code = e.product_code
where e.base_price>500 and e.promo_type ="BOGOF";



select city ,count(store_id) as "Stores" from dim_stores 
group by city 
order by Stores desc;



with cte1 as(
select c.campaign_name,e.*,
case
when e.promo_type="50% OFF" then e.base_price/2
when e.promo_type="25% OFF" then e.base_price/4
when e.promo_type="33% OFF" then e.base_price/3
when e.promo_type="500 Cashback" then e.base_price-500
when e.promo_type="BOGOF" then e.base_price/2
End as pricenew
from fact_events e
join dim_campaigns c
on e.campaign_id=c.campaign_id
)
select 
campaign_name,
sum(base_price * quantity_sold_before_promo/1000000) as total_rev_before_promo_millions,
sum(pricenew * quantity_sold_after_promo/1000000)as total_rev_after_promo_millions
from cte1
group by campaign_id;




with cte2 as (
select e.*,p.category,
((sum(quantity_sold_after_promo)/sum(quantity_sold_before_promo))-1)*100 as ISU
 from fact_events e 
 join dim_products p
 on p.product_code=e.product_code
 where campaign_id="CAMP_DIW_01"
  group by p.category
 )
 select campaign_id,category,ISU,
 rank() over (order by ISU desc) as "Rankings by ISU%" from cte2
 ;



with cte3 as(
select e.promo_type,e.base_price,e.quantity_sold_after_promo,
e.quantity_sold_before_promo,
p.product_name,p.product_code,p.category,

case
when e.promo_type="50% OFF" then e.base_price/2
when e.promo_type="25% OFF" then e.base_price/4
when e.promo_type="33% OFF" then e.base_price/3
when e.promo_type="500 Cashback" then e.base_price-500
when e.promo_type="BOGOF" then e.base_price/2
End as pricenew
from fact_events e
join dim_products p
on p.product_code = e.product_code

)
select  product_code,product_name,
((sum(pricenew*quantity_sold_after_promo) /
sum(base_price * quantity_sold_before_promo))-1 )*100 as IRper
from cte3
group by product_code
order by IRper desc limit 5;