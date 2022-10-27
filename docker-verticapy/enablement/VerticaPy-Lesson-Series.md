# VerticaPy Lesson Series

## Introduction

This document is an overview of how to use the Jupyter Notebook templates to create lessons on data science concepts and VerticaPy. You can also look at [this video](https://www.youtube.com/watch?v=9UaltjUCHiU&ab_channel=Vertica) to follow along on how to create lessons. 

The core page types are as follows:

- **Course** : Contains video content and covers prerequisites and lesson goals.

- **Module Outline** : Contains a list of the lessons (including exercises, if any).
- **Lesson** : A lesson page goes into detail about a topic, or a portion of a topic. Complex topics often have several lesson pages; for example, you could break up a topic into a theory, application, and exercise page with sample problems.

A set of example pages (theory, application, exercise) is provided in the **/Data Science Essentials/LinearRegression**.

## Prerequisites

- ipywidgets (7.6.5 preferred)
- Ipython
- voila (0.3.6 preferred).

**Note** : The current version of vertica-demo has all the these prerequisites, so you do not need to create your own environment.

Basic usage

- To view an existing Jupyter Notebook's webpage layout, open the Notebook and click the **voila** button on the top ribbon. If links do not work, their references need to be updated.
- To edit Jupyter Notebook cells, double-click them. To create new cells, copy the type of cell and paste them; this helps preserve styling between cells.
- Comments are used to highlight where edits can be made.
- **The Header Bar in all pages should not be changed**. It is the responsibility of the main owner of the entire enablement module because it will have quick links to examples, documentation etc.

## Page Types

The following sections go into detail about the core page types and how they should be structured.

### Course

**Video** : Each course page should have a video that demonstrates the course topic(s). The video file must be stored in the  **course\_title/Figures** directory and named **Video\_1.mp4**. (The instructions of how to create the video are summarized in this [video here](https://www.youtube.com/watch?v=btLUNGKmz8g&ab_channel=Vertica).)

**Description** : Add a brief, high-level description of the course topics, focusing on the motivation and its applications. This can be added in the cell commented as "# Video, Brief Description & Highlights".

**Highlights** : A short list of the highlights of the course. This can be added in the cell commented as "# Video, Brief Description & Highlights". Edit the three template highlights by replacing the text inside the "\<b\> … \</b\>". Please have at least three highlight texts. If more need to be added, then follow the procedure below:

1. Copy and paste the following line in the same cell right after the current place: highlight\_3 = widgets.HTML(value="\<b\>Highlight 3\</b\>")
2. In the above line, replace "highlight\_3=" with" highlight\_4="
3. Edit the highlight inside the \<b\> … \</b\>
4. Copy and paste the following line in the same cell right after the current place: highlight\_3.add\_class('highlight\_each\_style')
5. In the above line, replace "highlight\_3.add\_class" with "highlight\_4.add\_class"
6. Now add the new highlight created in the widget box by editing the following line:highlights=widgets.HBox([highlight\_1,highlight\_2,highlight\_3],layout…
7. In the above line, add ",highlight\_4" after highlight\_3

**Let's start button:** Please update the URL link of this button to reflect the link of the Module Page of the first Module. To get the hyperlinks for each page, use Voilà and copy the address of the page. For example, to get a hyper link of **Module\_v1\_2.ipynb** ,copy and replace the existing address with the URL: [http://localhost:8888/voila/render/Documents/Template/Enablement%20Template/Module\_v1\_2.ipynb](http://localhost:8888/voila/render/Documents/Template/Enablement%20Template/Module_v1_2.ipynb).

Note that this web address contains "voila" after the host and port.

**Difficulty and Time** :You can add time in minutes or hours. Difficulty levels are: Easy, Intermediate, Hard. Edit this in the cell: #The Time and Difficulty Level

**Prerequisites** : List prerequisites, if any. Use bullet points if there is more than one. Copy the template bullet style.

**Goals** : List the goals of the course, focusing on what a user might want to get out of completing the course. Copy the template bullet style.

**Modules:** Add the list of the modules and lessons as hyperlinks in the last cell. To get the hyperlinks for each page, use Voilà and copy the address of the page. For example, to get a hyper link of **Module\_v1\_2.ipynb** ,copy and replace the existing address with the URL: [http://localhost:8888/voila/render/Documents/Template/Enablement%20Template/Module\_v1\_2.ipynb](http://localhost:8888/voila/render/Documents/Template/Enablement%20Template/Module_v1_2.ipynb).

Note that this web address contains "voila" after the host and port.

Feel free to copy and past lines to add more lessons. Do not forgot to update the titles of all the modules, lessons and exercises. The name of "Main Page" link stays the same and it leads to the Module Page for that particular module.

### Module Outline

Tasks:

- Update the lesson title, difficulty level and time requirement.
- Add a video highlighting important aspects of all the lessons in the module. Save the video using the following format: "Video\_ModuleName.mp4". For example, for Linear Regression, this would be "Video\_LinearRegression.mp4". (The instructions of how to create the video will be shared separately.)
- Update the hyperlinks for the lessons and exercises in the last cell.
- Update the names of the lessons as well as the time estimates for each.
- To add a new lesson/exercise just copy and past everything in between \<!--START - ONE LESSON--\> and \<!--END - ONE LESSON--\>. Then update the contents.

### Lesson

Lesson pages contain the detailed content and are the primary focus of a course. A course can have several lesson pages.

Tasks:

- Update the **Module Name** and **Lesson Name**.
- Update the hyperlink for the "Module Name" hyperlink so it points to the module page.
- Update the estimated time to complete the lesson.
- Add a brief introduction and explain why the lesson is important.
- Update the **Table of Contents** and add references to each header, where each header contains: **\<a id="** _ **CELL\_NAME** _ **"\>\</a\>** and each link in the **Table of Contents** contains: **text (#CELL\_NAME)**.
- Explain the lesson goals.
- If you use images, add them to their own separate cells so they can be referenced individually. If you want more control over the display of the image size then use Python directly as shown in example on the template.
- To add interactive, multiple-choice "Knowledge Checks," use the **create\_multipleChoice\_widget()** function
- To add code snippets in Markdown, use the following format in a cell:

'''Python

_ **python code** _

'''

- To add a video, reference the video path.
- At the end of the lesson, add the author's name and contact information.
- Add any citations used.

#### Exercise

An exercise is a special type of lesson page that gives the reader some problems to solve. The types of questions available are:

- Multiple-choice
- Short numeric answer

## Page Names

Pages should be named according to the following format:

**CourseName_ModuleName_LessonName**

For example:

Essentials\_LinearRegression\_Theory

In addition, each module should have its own directory inside the **Course** directory.

## Directories

All Jupyter Notebook pages should be placed inside their respective **Module** directories, which itself is located in the **Course** directory. That is, the hierarchy should be:

**Course folder** \> **Module Folder** \> **Module-related pages**

For example, the linear regression module contains three pages, and these pages are inside the **Data Science Essentials** directory.

Modules can contain additional directories **Figure** and **Data** directories for for images/icons and data, respectively.

## Courses and Curriculums

Data science is a vast field, so the goal is to focus on the most common topics for now. Anyone is welcome to suggest a course or curriculum.

Data Science is a vast field with lots of rabbit holes, so we want to stick to the most common ones initially. Anyone is welcome to suggest a course or curriculum.

For example, the curriculum for the **Data Science Essentials** course is as follows (each bullet is a module and sub-bullet is a lesson):

**Data Science Essentials**

- _Overview of Data Science_
  - Basic terminology
  - Datasets
  - vDataFrame
- _Basic data ingestion_
  - Data types (tabular, unstructured etc.)
  - Data formats (csv, image, text, etc.)
- _Basic data exploration_
  - Descriptive Statistics
  - Visualizations
    - Types of plots (pie charts, histograms, etc.)
  - Dimension reduction (TSNE, PCA)
- _Basic data preparation_
  - Basic operations
    - Impute
    - Null or missing values
    - Normalize
    - Concatenate and Transform
  - Advanced operations
    - Outlier detection
  - Test/Train split
- _Linear Regression_
  - Theory
  - Example Application
  - Exercise
- _Classification_
  - Binary - Logistic Regression
  - Binary - Example Application
  - Multiclass - Random Forest
  - Multiclass- Example Application
- _Project_
