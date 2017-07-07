import csv
import sqlite3
import pandas as pd
from datetime import timedelta, date

def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)

start_date = date(2017, 5, 2)
end_date = date(2017, 5, 3)
for single_date in daterange(start_date, end_date):
    curr_date=single_date.strftime("%Y-%m-%d")
    #Read from csv
    df = pd.read_csv(filepath_or_buffer='/home/nishanksb/Downloads/bmfeq_ftp_data/OFER_VDA_20170502_FILTERED_nospace.TXT'\
                    , delimiter=';', header=None, usecols=[1,2,3,5,6,8,9,10,11,13], \
                    names=["symbol", "buy_sell", "seq_o_no", "exec_type", "time","price", "total_qty", "traded_qty", "date", "order_status"],\
                    dtype = {"symbol": str, "buy_sell":int, "seq_o_no":int, "exec_type":int, "time": str,"price":float, "total_qty":int, "traded_qty":int, "order_status": str}, parse_dates=[7]);

    #Filter Trades (Consider date for current trade date, filter only certain combinations)
    # Execution Type  Order Status
    # processing these for now
    # 001 0
    # 002 5
    # 003 4
    # 004 1
    # 004 2

    # ignoring iceberg orders
    # 005 0
    # 005 1

    # ignoring these
    # 011 C
    df = df[(df.date == curr_date) & (((df.exec_type==1) & (df.order_status=='0')) | ((df.exec_type==2) & (df.order_status=='5')) | \
            ((df.exec_type==3) & (df.order_status=='4')) | ((df.exec_type==4) & (df.order_status=='1')) | \
            ((df.exec_type==4) & (df.order_status=='2')))]

    product_list = df.symbol.unique()
    for sym in product_list:
        prod_wise_df = df[(df.symbol==sym)]
        order_no_list = prod_wise_df.seq_o_no.unique()
        for curr_son in order_no_list:
            min_time_idx=prod_wise_df[(prod_wise_df.seq_o_no == curr_son)].time.idxmin()
            print(prod_wise_df.iloc[[min_time_idx]].exec_type)
