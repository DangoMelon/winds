#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""
Created on Tue Jun 4 01:50:48 2019
Author: Gerardo A. Rivera Tello
Email: grivera@igp.gob.pe
-----
Copyright (c) 2019 Instituto Geofisico del Peru
-----
"""

import os
import pandas as pd
import datetime

base_dir = "/data/datos/ASCAT/DATA_L4_bin/"
years = os.listdir(base_dir)
years = [os.path.join(base_dir,year) for year in years if len(year)==4]

for year_path in years:
    year = year_path[-4:]
    time_limit = f'12-31-{year}'
    if year == '2019':
        time_limit = pd.to_datetime(datetime.date.today()) - pd.Timedelta(2,'D')
    full_series = pd.date_range(f'01-01-{year}',time_limit,freq='D').to_series()
    files = os.listdir(year_path)
    files = [pd.to_datetime(file[:-4],format="%Y%m%d") for file in files]
    for m_date in full_series:
        if m_date not in files:
            print("Date {:%Y-%m-%d} not found".format(m_date))