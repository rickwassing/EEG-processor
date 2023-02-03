**MARK BAD CHANNELS & EPOCHS**

In this video we'll introduce the Visual Inspection application and show you how to mark bad epochs and bad channels.



==========================
Mark bad channels & epochs
==========================

- Select a single file in the files-tree in the left center tab.
- Use the "Inspect" button to open the Visual Inspection application.

.. note::

    **Select the entire bad epoch including filter artefacts.** When an artefact occurs in the EEG, there is often a bit before and after the artefact where the EEG "ramps" up or down. This is likely due to temporal filtering. It is important to include these "ramps" for rejection of bad epochs. Otherwise, if these ramps are not rejected, the resulting EEG data after bad epoch rejection can have large "jumps" because the last datapoint before the artefact could have a very different value as the first datapoint after the bad epoch. This is especially bad when performing ICA, as this algorithm has to dedicate components to explain this artefactual variance in the data. Instead, try to start the bad epoch at the last datapoint of baseline activity before the artefact, and end the bad epoch at the first datapoint where the EEG data has returned to baseline activity.

----

:Video chapters:

    0:00 Starting the Visual Inspection application

    0:56 How to use the Visual Inspection application

    16:30 Inspecting the EEG data

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/qMYy-sL__18" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

----