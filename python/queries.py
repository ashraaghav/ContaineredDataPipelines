def query_brand_rank():
    """ Query to calculate the KPI brand rank based on avg. price of products """
    pg_query = """
            SELECT 
                brand,
                RANK () OVER (ORDER BY avg(price) DESC) rank 
            FROM store.products 
            GROUP BY brand;
            """
    return pg_query


def query_min_max_hdd():
    """" Calculates the KPI min & max HDD size (in GB) """
    pg_query = """
            SELECT 
                min(hdd_gb) AS min_hdd, 
                max(hdd_gb) as max_hdd 
            from store.products;
            """
    return pg_query

def query_median_ghz():
    """" Calculates the KPI median GHz per RAM_GB """
    pg_query = """
            SELECT 
                ram_gb, 
                PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_ghz
            FROM store.products 
            GROUP BY ram_gb;
            """
    return pg_query
