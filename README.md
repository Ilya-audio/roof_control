# Roof|control
### A new JSFX plugin for phones-correction and mix-checking

Hi everyone!

I'm a mixing engineer. In late 2025, I moved from Russia to Serbia, where I planned to build my new home studio. As is often the case, construction got delayed, and I was forced to switch to monitoring exclusively on headphones. Honestly, I’ve never been a fan of that idea, but I had no choice. Working "raw" in headphones felt impossible for me, so I started looking for a solution.

I own licenses for several commercial monitoring plugins, but I really wanted a native, lightweight Linux solution. Ultimately, I took the algorithms that worked best for me, combined them into a single JSFX plugin, and added the specific features I needed for my daily workflow.

---

<p align="center">
  <img width="1280" alt="Roof|control Interface" src="https://github.com/user-attachments/assets/b9e102aa-4416-4a51-a16f-ff310ec171f9" />
</p>

---

## Main Modules

### 1. Speaker Emulation Module
Allows you to quickly check your mix across various sound sources:
* **Main Monitors** – Transparent mode with no processing. This is the primary mode for mixing.
* **Cubes** – Emulation of the famous Auratone "mix cubes."
* **Vinyl** – A faithful recreation of the mode found in AirWindows Monitoring 3.
* **Smartphone** – Mobile speaker simulation (based on Monitoring 3).
* **SLEW** – (The mysterious device on the right side of the desk) A detector for "fast" events in the mix. Great for identifying transient-related issues.
* **Subwoofer** – A recreation of the Monitoring 3 mode for checking low-end conflicts.
* **Fullrange** – A custom mode I built by combining modes 1 and 6 (activated by clicking on the central control deck). It mimics the feel of home theaters or club systems.

### 2. Headphone Correction Block
The plugin utilizes profiles from the AutoEQ project (though you are free to use your own measurements).

### 3. True-Stereo Block
Based on the well-known BS2B project, but with one significant modification. The original author of BS2B intentionally omitted a delay for the crossfeed signal. I have added an **ITD (Interaural Time Difference)** parameter, which significantly improves the naturalness and perceived width of the stereo image.

> **Note:** This module is active only for the following modes: Main, Cubes, Vinyl, and Fullrange.

---

## Installation

1. **Download:** Get the latest release from the [Releases page](https://github.com/Ilya-audio/roof_JSFX_scripts/releases).
2. **Install:** Extract the contents into your **REAPER Resource Path**.
3. **Get and Setup your Profile:**
    * Go to [autoeq.app](https://autoeq.app) and find your headphone model.
    * In the **Select Equalizer App** dropdown, choose **Custom Parametric EQ**.
    * Adjust filters: Check if there are more "useful" filters available (AutoEQ defaults to 5).
    * Download the `.txt` profile and place it into: `*reaper resource folder*/Data/roof_control/phones_eq`.
5. **Run Backend:** Go to the "Actions" menu, add and run the `roof_bubrik.lua` satellite script. 
   * *Note: JSFX has limited file-handling, so this script is essential. If you use SWS, add it to your startup actions.*
6. **Load Plugin:** Open **JS: roof|control**. Place it in the **Monitoring FX** section AFTER all your meters.

---

## Fine-tuning

* **Configuration:** Click the headphone on the desk to select your profile.
* **Gain:** Gain: Adjust the Gain slider so that toggling correction doesn't change the overall volume. Double-clicking the slider restores the value saved in your profile, and the SAVE button writes your current setting back to the file.
* **True Stereo Setup:**
    1. Send only the Left or Right channel into the plugin.
    2. Adjust the **cutoff** until you achieve a comfortable tone (700-800 Hz).
    3. Switch back to stereo and adjust **suppression**.
    4. Send only the Left or Right channel into the plugin.
    5. Gradually increase the **ITD** to open up the soundstage.
    * *My sweet spot: cutoff 800, suppression 6 dB, ITD 0.12 ms.*

## Known Features
* File operations require the `roof_bubrik.lua` script to be running.
* Global Synchronization (gmem):
The plugin is designed to function as a single, unified monitoring hub. Because of the external control system (which allows you to switch modes via toolbar buttons or scripts), all instances of the plugin will stay synchronized. You only need one copy of the plugin in your Monitoring FX chain to control your entire setup.
* REAPER Exclusive: This plugin is designed specifically for REAPER. Due to the heavy use of shared memory (gmem) and the backend script, it will not work in other JSFX hosts (like ysfx).
---

**P.S. Why the name "roof_bubrik"?**
I have a studio cat named **Bubrik**. She is in charge of comfort and constantly monitors the operating temperature of my gear. She’s a vital team member—without her, everything would fall apart. Since the background script performs a similar "maintenance" role, I decided to name it after her. :)

<p align="center">
<img width="1195" height="675" alt="Bubrik" src="https://github.com/user-attachments/assets/ce03f4d3-d99f-46f1-8b5a-a8b397afe632" />
</p>
