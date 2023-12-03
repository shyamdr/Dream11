def upsert(engine, dataFrame, table, schema, pk_col=None, update_col=None):
    
    dataFrame.to_sql("temp_table", con = engine, schema = "stg", method = "multi", if_exists="replace", index=False)
    
    col = list(dataFrame.columns)
    
    if not update_col:
        update_col = list(set(col).difference(pk_col))
    
    insert_col_list = ", ".join([f'"{col_name}"' for col_name in col])
    match_col_list = ", ".join([f'"{col_name}"' for col_name in pk_col])
    
    stmt = f"INSERT INTO {schema}.{table} ({insert_col_list})\n"
    stmt += f"SELECT {insert_col_list} FROM stg.temp_table\n"
    stmt += f"ON CONFLICT ({match_col_list}) DO UPDATE SET\n"
    stmt += ", ".join(
        [f'"{col}" = EXCLUDED."{col}"' for col in update_col]
    )
    with engine.begin() as conn:
        conn.exec_driver_sql(stmt)
        conn.exec_driver_sql("DROP TABLE IF EXISTS stg.temp_table")
        
    return stmt


def insert_without_duplicate(engine, dataFrame, table, schema, conflict_col):
    
    if len(dataFrame)==0:
        return("No records found.")
    
    dataFrame.to_sql("temp_table", con = engine, schema = "stg", method = "multi", if_exists="replace", index=False)
    
    col = list(dataFrame.columns)
    insert_col_list = ", ".join([f'"{col_name}"' for col_name in col])
    conflict_col_list = ", ".join([f'"{col_name}"' for col_name in conflict_col])
    
    stmt = f"INSERT INTO {schema}.{table} ({insert_col_list})\n"
    stmt += f"SELECT {insert_col_list} FROM stg.temp_table\n"
    stmt += f"ON CONFLICT ({conflict_col_list}) DO NOTHING;\n"

    with engine.begin() as conn:
        conn.exec_driver_sql(stmt)
        conn.exec_driver_sql("DROP TABLE IF EXISTS stg.temp_table")
        
    return stmt