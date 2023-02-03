**SELECT & PREPROCESS EEG DATA**

In this section we'll discuss the general steps to select a subset of your EEG recording and apply preprocessing steps to the selected data, e.g. interpolating channels, removing bad epochs, etc. There are also videos that specifically discuss how to select and preprocess resting-state (KDT) recordings and polysomnography recordings; see below.

:Video chapters:

    0:00 The output from the Visual Inspection Application

    1:16 Introducing Select and Preprocess

    2:50 Settings to select part of the EEG recording

    13:22 Settings to preprocess the selected EEG data

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/8iUL0es2cqo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

----

==========
Select EEG
==========

abc

----

=========================
Apply preprocessing steps
=========================

abc

----

=========================
Example: resting-state recording (KDT)
=========================

This video outlines the steps to (1) select a resting-state recording from an EEG recording spanning several tasks, (2) creating separate files for eyes-open and eyes-closed conditions and apply independent component analysis, (3) rejecting and removing components reflecting artifacts from eye movements, heart and other muscles.

:Video chapters:

    0:00 Introducing the example and ICA

    1:58 Selecting the resting-state task from the task-battery

    9:00 Checking the new output files

    9:50 Selecting the resting-state conditions

    12:52 Apply preprocessing and ICA to resting-state condition

    16:00 Marking components for rejection

    33:06 Removing rejected components to create clean data ready for analysis

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/c0cINx46Dak" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

----

==================================
Example: polysomnography recording
==================================

This video outlines the steps to select specific sleep stages and create clean output files ready for analysis.

:Video chapters:

    0:00 Select individual sleep stages
    
    4:01 Preprocess and clean the data

    6:01 Further split the data into epochs

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/QmNKJrUQoOk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

----