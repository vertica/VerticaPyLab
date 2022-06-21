#!/usr/bin/env python
# coding: utf-8

# (c) Copyright [2018-2022] Micro Focus or one of its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# AUTHOR : KHALED
#
#              ____________       ______
#             / __        `\     /     /
#            |  \/         /    /     /
#            |______      /    /     /
#                   |____/    /     /
#          _____________     /     /
#          \           /    /     /
#           \         /    /     /
#            \_______/    /     /
#             ______     /     /
#             \    /    /     /
#              \  /    /     /
#               \/    /     /
#                    /     /
#                   /     /
#                   \    /
#                    \  /
#                     \/
#                    _
# \  / _  __|_. _ _ |_)
#  \/ (/_|  | |(_(_|| \/
#                     /


# Python Modules
import ipywidgets as widgets
from ipywidgets import Layout, Box
from IPython.display import display, display_html, update_display
from IPython.core.display import HTML
# VerticaPy 
from verticapy import vDataFrame




# # Jupyter Widgets + vDataFrame

# ## vDataFrame.iloc



class interface_iloc:
    def __init__(self, vdf: vDataFrame, limit: int = 5):
        # Initializing the cursor and the output widget
        self.cursor = 0
        self.output = widgets.Output()
        # Creating the buttons
        self.btn_next = widgets.Button(description="Next",
                                       disabled=False,
                                       icon='fa-arrow-right')
        self.btn_previous = widgets.Button(description="Previous",
                                           disabled=True,
                                           icon='fa-arrow-left')
        int_slider = widgets.IntSlider(
                            value=5,
                            min=1,
                            max=100,
                            step=1,
                            description='Limit')
        # Storing the limit
        self.limit = int_slider.value

        # Storing the virtual dataframe
        self.vdf = vdf

        # Events Handlers
        self.btn_next.on_click(self.on_btn_next)
        self.btn_previous.on_click(self.on_btn_previous)
        int_slider.observe(self.onlimit_change, names="value")

        # Display the initial dataframe
        with self.output:
            self.display_iloc(limit=self.limit)
        # Layout&Styling
        items_layout = Layout(width='auto')
        box_layout = Layout(display='flex',
                            flex_flow='row',
                            align_items='center',
                            justify_content='space-around',
                            border='1px solid gray',
                            width='50%')
        self.box = Box(children=[self.btn_previous, int_slider, self.btn_next],
                       layout=box_layout)
        display(self.box, self.output)

    """
    ---------------------------------------------------------------------------
    display_iloc implements the iloc method from verticapy.vdataframe, which returns a part of the vDataFrame (delimited by an offset and a limit).

    Parameters
     ----------
    limit: int, optional
         Number of elements to display. (AS IN SQL LIMIT)
    offset: int, optional
         Number of elements to skip.  (AS IN SQL OFFSET)
    columns: list, optional
        A list containing the names of the vcolumns to include in the result. 
        If empty, all the vcolumns will be selected.
    """

    def display_iloc(self, limit: int = 5,
                     offset: int = 0, columns: list = []):
        with self.output:
            display(self.vdf.iloc(limit, offset, columns))

    # Handling what happens when the "NEXT" button is clicked
    def on_btn_next(self, value):
        self.cursor += self.limit
        self.output.clear_output(wait=True)
        if (self.cursor != 0):
            self.btn_previous.disabled=False
        with self.output:
            self.display_iloc(limit=self.limit, offset=int(self.cursor))

    # Handling what happens when the "PREVIOUS" button is clicked
    def on_btn_previous(self, value):
        self.cursor -= self.limit
        self.output.clear_output(wait=True)
        if (self.cursor == 0):
            self.btn_previous.disabled=True
        with self.output:
            self.display_iloc(limit=self.limit, offset=int(self.cursor))

    # Handling the change of IntSlider's value
    def onlimit_change(self, change):
        self.limit = change['new']
        self.output.clear_output(wait=True)
        with self.output:
            self.display_iloc(limit=self.limit, offset=int(self.cursor))




# ## Descriptive Statistics
# 
# Full documentation of VerticaPy's Descriptive Statistics methods available here :
# href="https://www.vertica.com/python/documentation_last/vdataframe/statistics.php
#     


class stats_interactive:
    def __init__(self, vdf: vDataFrame):
        # Initializing the output widget and the columns list
        self.output = widgets.Output()
        self.cols = vdf._VERTICAPY_VARIABLES_['columns']
        # Creating the dropdowns
        self.dropdown = widgets.SelectMultiple(
                                                options=self.cols,
                                                value=[self.cols[0],
                                                       self.cols[1]],
                                                description='Column:',
                                                disabled=False
                                            )
        self.aggregate_dropdown = widgets.SelectMultiple(
                                                            options=['aad', 'approx_unique', 'approx_q%','approx_median',
                                                                     'cvar', 'dtype', 'iqr', 'kurtosis', 'count',
                                                                     'jb', 'mad', 'max', 'mean', 'median',
                                                                     'min', 'mode', 'percent', 'q%', 'prod',
                                                                     'range', 'sem', 'skewness', 'sum', 'std',
                                                                     'topk', 'topk_percent', 'std', 'unique', 'var'],
                                                            value=['aad', 'count'],
                                                            description='AggFunctions :',
                                                            disabled=False,
                                                            layout=Layout(width='auto')
                                                    )
        self.agg_param = None
        # Creating the buttons
        self.describe_btn = widgets.Button(
                                            description='Describe',
                                            disabled=False,
                                            icon='fa-info-circle'
                                        )
        self.head_btn = widgets.Button(
                                            description='Head',
                                            disabled=True,
                                            icon='fa-table',
                                            button_style='primary'
                                        )
        self.median_btn = widgets.Button(
                                            description='Median',
                                            disabled = False
                                        )
        self.avg_btn = widgets.Button(
                                            description='AVG',
                                            disabled = False
                                        )
        self.help_btn = widgets.Button(
                                            description='Help on aggregate',
                                            disabled = False,
                                            icon='fa-question-circle'
                                        )
        self.agg_btn = widgets.Button(
                                            description='Agg',
                                            disabled = False,
                                            icon='fa-check-circle'
                                        )
        # Storing the virtual dataframe
        self.vdf = vdf
        # VerticaPy Logo
        file_ = open("./assets/index.png", "rb")
        image = file_.read()
        img = widgets.Image(
                                value=image,
                                format='png',
                                width=60,
                                height=30,
                            )
        # Events Handlers
        self.describe_btn.on_click(self.onDescribe)
        self.head_btn.on_click(self.onHead)
        self.median_btn.on_click(self.onMedian)
        self.avg_btn.on_click(self.onAvg)
        self.help_btn.on_click(self.onHelp)
        self.aggregate_dropdown.observe(self.onAggFunc, type='change', names='value')
        self.agg_btn.on_click(self.onAgg)
        # Display the initial dataframe
        with self.output:
            display(self.vdf.head())
        # Layout&Styling
        box_layout = Layout(display='flex',
                            flex_flow='row',
                            align_items='flex-start',
                            justify_content='space-around',
                            width='100%',
                            margin='10px'
                           )
        self.box1 = Box(children=[self.describe_btn, self.median_btn, self.avg_btn, self.head_btn], layout=box_layout)
        self.box2 = Box(children=[self.agg_btn, self.help_btn], layout=box_layout)
        self.container = Box(children=[img, self.dropdown, self.box1, self.aggregate_dropdown, self.box2],
                             layout=Layout(
                                            display='flex',
                                            align_items='center',
                                            flex_flow='column',
                                            justify_content='space-between',
                                            width='100%',
                                            border='2px solid gray',

                                            )
                            )
        display(self.container, self.output)

    def onAggFunc(self, value):
        agg_func = value['new']
        if agg_func[0] in ['q%', 'approx_q%']:
            new_param = widgets.FloatSlider(min=0,
                                            max=100.0,
                                            step=0.1,
                                            description='%',
                                            readout_format='.2f')
        elif agg_func[0] in ['topk', 'topk_percent']:
            new_param = widgets.IntSlider(min=0,
                                          max=100,
                                          step=1,
                                          description='k')
        if new_param:
            if self.agg_param is None:
                self.agg_param = new_param
                self.container.children += (self.agg_param,)
            else:
                self.agg_param = new_param
                self.container.children = (*self.container.children[:-1], self.agg_param)


    def onDescribe(self, value):
        self.output.clear_output(wait=True)
        with self.output:
            display(self.vdf[self.dropdown.value].describe())
        self.head_btn.disabled = False

    def onMedian(self, value):
        self.output.clear_output(wait=True)
        with self.output:
            display(self.vdf[self.dropdown.value].median())
        self.head_btn.disabled = False

    def onAvg(self, value):
        self.output.clear_output(wait=True)
        with self.output:
            display(self.vdf[self.dropdown.value].avg())
        self.head_btn.disabled = False

    def onHead(self, value):
        self.output.clear_output(wait=True)
        self.head_btn.disabled = True
        with self.output:
            display(self.vdf.head())

    def onHelp(self, value):
        self.output.clear_output(wait=True)
        self.head_btn.disabled = False
        with self.output:
            display(help(self.vdf.agg))

    def onAgg(self, value):
        self.output.clear_output(wait=True)
        self.head_btn.disabled = False
        aggFunc = self.aggregate_dropdown.value[0]
        if aggFunc == 'topk_percent':
            aggFunc = 'top{}_percent'.format(self.agg_param.value)
        if aggFunc == 'q%':
            aggFunc = '{}%'.format(self.agg_param.value)
        if aggFunc == 'approx_q%':
            aggFunc = 'approx_{}%'.format(self.agg_param.value)
        if aggFunc == 'topk':
            aggFunc = 'top{}'.format(self.agg_param.value)
        with self.output:
            display(self.vdf[self.dropdown.value]\
                        .aggregate(func=aggFunc))


"""
visualizer class : handles verticapy's plots
	args: 
	 -vdf: verticapy's virtual DataFrame
"""
class visualizer:
    def __init__(self, vdf: vDataFrame):
        # Initializing the output widget and the columns list
        self.output = widgets.Output()
        self.cols = vdf._VERTICAPY_VARIABLES_['columns']

        # The columns list selection
        # Multiple values can be selected with shift and/or ctrl (or command) pressed and mouse clicks or arrow keys.
        self.cols_list = widgets.SelectMultiple(
                                                    options=self.cols,
                                                    value=[self.cols[0], self.cols[1]],
                                                    description='Columns :'
                                                )
        # The dropdown for the charts list
        self.charts_list = widgets.Dropdown(
                                                options=['hexbin','hist','bar',
                                                         'boxplot','pivot_table'],
                                                value='bar',
                                                description='Chart :'
        )
        self.charts_list.observe(self.onChartChange)
        # The selection for the method to use to aggregate the data.
        self.method_list = widgets.Dropdown(
                                                options=['count','AVG','Density',
                                                         'Mean','Min','Max','Sum'],
                                                value='count',
                                                description='Method :'
        )

        # Hist type option for histogram
        self.hist_type = widgets.Dropdown(
                                                options=['auto','multi','stacked'],
                                                value='auto',
                                                description='Hist type :'
        )
        self.hist_type.layout.visibility = 'visible'

        # The vcolumn to use to compute the aggregation
        self.of_col = widgets.Dropdown(
                                        options=self.cols,
                                        value=self.cols[0],
                                        description='Of :'
        )
        # Creating the buttons
        self.visualize_btn = widgets.Button(description="Visualize", 
                                            layout=Layout(margin='10px'),
                                            icon='fa-bar-chart',
                                            button_style='primary')

        barWidth_slider = widgets.FloatRangeSlider(
                                                    value=[0.1, 1.0],
                                                    min=0,
                                                    max=100,
                                                    step=0.1,
                                                    description='Width : (if 0, Optimized)',
                                                    layout=Layout(width='300px', margin='10px'),
                                                )

        # Storing the window's width
        self.width = barWidth_slider.value

        # Storing the virtual dataframe
        self.vdf = vdf

        # Events Handlers
        self.visualize_btn.on_click(self.on_visualize_btn)
        barWidth_slider.observe(self.onWidthChange, names="value")
        # VerticaPy Logo
        file = open("./assets/index.png", "rb")
        image = file.read()
        img = widgets.Image(
                                value=image,
                                format='png',
                                width=60,
                                height=35,
                                layout=Layout(margin='15px')
                            )
        # Layout&Styling
        box_layout = Layout(
                                display='flex',
                                flex_flow='row',
                                align_items='flex-start',
                                justify_content='space-between',
                                width='100%',
                                margin='5px'
                            )

        box = Box(children=[img, self.cols_list], layout=box_layout)
        options1 = Box(children=[self.charts_list, self.method_list], layout=box_layout)
        options = Box(children=[self.of_col, self.hist_type], layout=box_layout)
        options_= Box(children=[barWidth_slider, self.visualize_btn], layout=box_layout)
        self.container = Box(children=[box, options1, options, options_], layout=Layout(display='flex',
                                                                                        align_items='center',
                                                                                        flex_flow='column',
                                                                                        justify_content='center',
                                                                                        width= '70%',
                                                                                        border='solid 2px gray',
                                                                                        margin='10px'
                                                                                )
                            )
        display(self.container, self.output)

    def on_visualize_btn(self, value):
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(figsize=(12,8))
        self.output.clear_output(wait=True)
        chart = self.charts_list.value
        cols = list(self.cols_list.value)
        if chart == 'bar':
            self.output.clear_output(wait=True)
            with self.output:
                self.vdf.bar(ax=ax, columns=cols, h=self.width, method=self.method_list.value, of=self.of_col.value, hist_type=self.hist_type.value)
                plt.show()
        if chart == 'hist':
            self.output.clear_output(wait=True)
            with self.output:
                self.vdf.hist(ax=ax, columns=cols, h=self.width, method=self.method_list.value, of=self.of_col.value, hist_type=self.hist_type.value)
                plt.show()
        if chart == 'hexbin':
            self.output.clear_output(wait=True)
            with self.output:
                self.vdf.hexbin(ax=ax, columns=cols, method=self.method_list.value, of=self.of_col.value)
                plt.show()
        if chart == 'boxplot':
            self.output.clear_output(wait=True)
            with self.output:
                self.vdf[cols].boxplot(ax=ax)
                plt.show()
        if chart == 'pivot_table':
            self.output.clear_output(wait=True)
            with self.output:
                self.vdf[cols].pivot_table(ax=ax, columns=cols, h=self.width, of=self.of_col.value)
                plt.show()

    # Handling the change of Window's width value
    def onWidthChange(self, change):
        self.width = change['new']

    def onChartChange(self, change):
        if change['new'] in ['hist','bar'] :
            self.hist_type.layout.visibility = 'visible'
        if change['new'] == 'boxplot' :
            self.of_col.layout.visibility = 'hidden'
            self.hist_type.layout.visibility = 'hidden'
        else:
            self.of_col.layout.visibility = 'visible'
# ## Features Engineering (vDataFrame.eval + vDataFrame.sessionize)

# <strong>vDataFrame.sessionize :</strong> Adds a new vcolumn to the vDataFrame which will correspond to sessions (user activity during a specific time). A session ends when ts - lag(ts) is greater than a specific threshold.
# <br>
# <strong>vDataFrame.eval :</strong> Evaluates a customized expression

class eval_sessionize:
    def __init__(self, vdf: vDataFrame):
        # Initializing the output widget and the columns list
        self.output = widgets.Output()
        self.cols = vdf._VERTICAPY_VARIABLES_['columns']
        # vcolumn used as timeline
        self.cols_dropdown = widgets.Dropdown(
                                                options=self.cols,
                                                value=self.cols[0],
                                                description='TS :',
                                            )
        # vcolumns used in the partition.
        self.cols_select_mult = widgets.SelectMultiple(
                                                options=self.cols,
                                                value=[self.cols[0],self.cols[1]],
                                                description='BY :',
                                            )
        # Name of the new vcolumn (the result of eval)
        self.new_vcol_name = widgets.Text(
                                                placeholder='new_vcol_name',
                                                value='',
                                                description='Name :',
                                            )
        self.threshold = widgets.IntText(
                                            value=10,
                                            description='Threshold :',
                                            layout=Layout(width='150px')
                                        )
        self.session_name = widgets.Text(
                                            value='',
                                            placeholder='session_id',
                                            description='Session Name :',
                                            layout=Layout(width='auto')
                                        )
        self.expression = widgets.Textarea(
                                            value='',
                                            placeholder='PURE SQL!',
                                            description='Expression :',
                                        )
        # Creating the buttons
        self.eval_btn = widgets.Button(
                                            description='Eval',
                                            icon = 'fa-check-circle',
                                            button_style='primary'
                                        )
        self.sessionize_btn = widgets.Button(
                                            description='Sessionize',
                                            icon = 'fa-check-circle',
                                            button_style='primary'
                                        )
        self.vdf = vdf
        
        # Events Handlers
        self.eval_btn.on_click(self.onEval)
        self.sessionize_btn.on_click(self.onSessionize)
        
        # Display the initial dataframe
        with self.output:
            display(self.vdf.head())
        # VerticaPy Logo
        file = open("./assets/index.png", "rb")
        image = file.read()
        img = widgets.Image(
                                value=image,
                                format='png',
                                width=60,
                                height=30,
                                margin='5px',
                            )
        # Layout&Styling
        box_layout = Layout(
                                display='flex',
                                flex_flow='row',
                                align_items='flex-start',
                                justify_content='space-around',
                                width='100%',
                                margin='5px'
                           )
        self.box1 = Box(children=[self.cols_dropdown, self.cols_select_mult, self.threshold, self.session_name], layout=box_layout)
        self.box2 = Box(children=[self.new_vcol_name, self.expression], layout=box_layout)

        self.container = Box(children=[img, self.box1,self.sessionize_btn, self.box2, self.eval_btn], layout=Layout(
                                                                                                                        display='flex',
                                                                                                                        align_items='center',
                                                                                                                        flex_flow='column',
                                                                                                                        justify_content='space-between',
                                                                                                                        width= '100%',
                                                                                                                        border='solid 2px gray',
                                                                                                                        margin='5px'
                                                                                                                    )
                            )
        display(self.container, self.output)

    """
    ---------------------------------------------------------------------------

     F1   vDataFrame.sessionize

    ---------------------------------------------------------------------------
    Adds a new vcolumn to the vDataFrame which will correspond to sessions 
    (user activity during a specific time). A session ends when ts - lag(ts) 
    is greater than a specific threshold.

    Parameters
    ----------
    ts: str
        vcolumn used as timeline. It will be to use to order the data. It can be
        a numerical or type date like (date, datetime, timestamp...) vcolumn.
    by: list, optional
        vcolumns used in the partition.
    session_threshold: str, optional
        This parameter is the threshold which will determine the end of the 
        session. For example, if it is set to '10 minutes' the session ends
        after 10 minutes of inactivity.
    name: str, optional
        The session name.

    Returns
    -------
    vDataFrame
        self
        
    ---------------------------------------------------------------------------
    
    F2    vDataFrame.eval
     
    ---------------------------------------------------------------------------

    Evaluates a customized expression.

    Parameters
    ----------
    name: str
        Name of the new vcolumn.
    expr: str
        Expression to use to compute the new feature. It must be pure SQL. 
        For example, 'CASE WHEN "column" > 3 THEN 2 ELSE NULL END' and
        'POWER("column", 2)' will work.

    Returns
    -------
    vDataFrame

    """
    def onSessionize(self, value):
        #print(self.cols_select_mult.value+[self.cols_dropdown.value])
        self.vdf.sessionize(ts=self.cols_dropdown.value, by=list(self.cols_select_mult.value), session_threshold=str(int(self.threshold.value))+" minutes", name=self.session_name.value)
        self.output.clear_output(wait=True)
        with self.output:
            display(self.vdf.head())
    
    def onEval(self, value):
        self.vdf.eval(name=self.new_vcol_name.value, expr=self.expression.value)
        self.output.clear_output(wait=True)
        with self.output:
            display(self.vdf.head())


