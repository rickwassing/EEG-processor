==============
EEG Processor
==============

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/hSgykhutalc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

----

The EEG Processor is a Matlab application to import, preprocess and analyse EEG recordings. All files will be automatically named and organized according to the specifications of the `Brain Imaging Dataset Structure <https://bids-specification.readthedocs.io>`_.

.. important::

  The EEG Processor application cannot handle just any EEG file. The app has been developed specifically for the sleep-lab at the Woolcock Institute of Medical Research, Sydney, Australia where we obtain high-density EEG recordings using the EGI-Philips and Compumedics 257-channel EEG systems.

  Please contact Rick Wassing if you want to make sure the EEG Processor can handle your dataset. We may need to write some custom import functions.

The Brain Imaging Dataset Structure
-----------------------------------

The Brain Imaging Data Structure (BIDS) is a set of rules and guidelines by which you can organize and describe your neuroimaging dataset. Without BIDS, two researchers may not use the same file-naming strategy, or use dissimilar folder-structures. This results in confusion and time wasted on trying to understand the dataset structure and adapt code to analyse these datasets. It also hampers combining datasets and collaboration. The BIDS aims to solve all of these issues. 

.. note::

  It is strongly recommended to first familiarize yourself with the `BIDS Specification <https://bids-specification.readthedocs.io>`_. This documentation does not contain as much detail about the rules and recommendations.


Version 2.0.0
-------------

You may encounter bugs. If you do, please let me know and we'll get it sorted!

Authors
-------

- **Rick Wassing**, rick.wassing@sydney.edu.au, Woolcock Institute of Medical Research, The University of Sydney, Australia
- **Tancy Kao**, Woolcock Institute of Medical Research, The University of Sydney, Australia

.. hint::

  This app is an ongoing and open-source project supported by in-kind contributions. If this project resonates with you and you'd like to contribute, please contact Rick Wassing. Your help is most welcome, however small the contribution may be.

Download
--------

Click `here to download <https://github.com/rickwassing/EEG-Processor/archive/refs/heads/main.zip>`_ the EEG Processor application and all its Matlab code.

Dependencies
------------

- Fieldtrip (`fieldtriptoolbox.org <https://www.fieldtriptoolbox.org>`_)
- EEGLAB (`eeglab.org <https://eeglab.org>`_)
- Faster Toolbox (see Nolan, Whelan, Reilly (2010) FASTER: Fully Automated Statistical Thresholding for EEG artifact Reduction, J Neurosci Meth, 192(1), 152-62)

Limitations
------------

.. attention::

  The EEG Processor can only run in Matlab 2021a and later

As the name suggests, the EEG Processor can only import EEG data. Other neuroimaging modalities are not supported, and may never be, because other BIDS Apps are already available (see `Gorgolewski et al. <https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005209>`_ (2017) BIDS apps: Improving ease of use, accessibility, and reproducibility of neuroimaging data analysis methods. PLoS comp biol, 13(3), e1005209). Also, the EEG Processor can only import EEG data from EGI-Philips .MFF files, and Compumedics HD-EEG .EDF files.

.. toctree::
  :maxdepth: 1
  :caption: Getting started

  getting-started.rst

.. toctree::
  :maxdepth: 1
  :caption: My first subject and file

  first-subject-and-file.rst

.. toctree::
  :maxdepth: 1
  :caption: Edit files and apply processes

  edit-and-process-files.rst

.. toctree::
  :maxdepth: 1
  :caption: Mark bad channels & epochs

  marking-bad-channels-epochs.rst

.. toctree::
  :maxdepth: 1
  :caption: Select & Preprocess EEG data

  select-and-preprocess.rst

.. toctree::
  :maxdepth: 1
  :caption: Subject-level analyses

  power-spectral-analysis.rst

----