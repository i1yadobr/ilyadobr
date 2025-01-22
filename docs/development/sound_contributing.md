# Contributing and modifying sounds

This document outlines some of the important and often overlooked aspects of working with sound effects for the codebase.

It is intended as a reference list of what to look out for.  
It is not meant to be a detailed instruction on any of the mentioned aspects, nor does it provide any information on the basics of working with sound.

If you have any questions or need clarification on topics mentioned here, feel free to reach out to the maintainers of the project.  
In fact, it is preferred that you do so, because your feedback might result in improvements to this document. In turn, this provides newcomers with better information and saves them the effort of looking for answers elsewhere.

## Summary
- Include license and authorship information, even if sound is free to use.
- Review and fill the metadata of audio files.
- Use 44.1kHz sample rate.
- Use/convert to mono audio unless stereo is actually necessary.
- Normalize loudness and test it in the game alongside other sounds.

## License
Please include license information for the sounds and samples that you're contributing. Good places to store licensing information are:
- A text file alongside the sound files or in a parent folder
- Metadata of the sound file
- Commit message
- PR description

Please check if license of the sound is compatible with the [license](/LICENSE.txt) of the codebase.

Even if the sound is free to use and doesn't require appropriate credit/mention of authorship, it is still a good practice to include that information where possible. This is not a hard requirement, but rather a recommendation to pay respect to people whose work we are using for our own projects. This fosters a healthy and respectful ecosystem, and is basically a display of good manners.

## Metadata
Please review and include metadata with your audio files, as it allows future contributors to backtrace the source of the audio even if filename changes, as well as receive additional information if it was provided in the comments.

It is not mandatory to fill all the default metadata fields.

Metadata for sounds is similar to code comments. While filename alone could be sufficient to trace the sound effect and find all the necessary information about it, it is not always possible to track which modifications were made to the sound, who was the author of the modifications, what is the source of this specific iteration of the sound, and what is the license.

Metadata allows future contributors to find that information and make informed decisions regarding the files that you're working on and (usually) have more context for.

One approach to editing the metadata with support for templates is using free and open-source Audacity, see here for more details: https://manual.audacityteam.org/man/metadata_editor.html.

## Sample rate
For audio effects and samples use mono audio with 44.1kHz sample rate. This specific sample rate is required in order to allow audio system to dynamically vary the effect.

This, alongside slight variation in volume of the sound effect each time it is played, is used to avoid audio fatigue, where players get overexposed to a specific sound and either get annoyed by it or stop paying attention and start perceiving it as background noise.

The technique is called audio/sound effect variation. In this codebase a very simplistic approach is used. Sound effects that might be repetitive are played at:
- varying [volume](https://www.byond.com/docs/ref/#/sound/var/volume): using rand(min_volume,max_volume) function
- varying pitch/speed: changing the [frequency](https://www.byond.com/docs/ref/#/sound/var/frequency) in range from 32kHz to 55kHz.

The frequency change relies on sound files to be at 44.1kHz, as min and max values are currently harcoded. This is applied in /proc/get_rand_frequency(), [code/_helpers/sound.dm](/code/_helpers/sound.dm).

## Normalize volume
Sounds that you may find on the internet come at a wide range of loudness. Some sounds are really quiet, others will unnecessarily blast ears of the players.

When working with sounds, find a sound similar to the one you're adding or editing, and compare them side by side in an audio editor, e.g. free to use [Audacity](https://www.audacityteam.org/) or paid [Adobe Audition](https://www.adobe.com/products/audition.html).

Try to preserve the original audio as much as possible, as each change to the loudness will result in some information loss or artifacts.

If the audio is too loud in its native form compared to other samples in the codebase, reduce it slightly until waveform amplitudes are about the same. Keep in mind that volume can and often is further reduced in the game itself by using the [volume](https://www.byond.com/docs/ref/#/sound/var/volume) parameter.

If the audio is too quiet, given that the game engine is not used to amplify sound, apply normalization or sound amplification through audio editing software.  
It is not necessary to bring peaks to the same level as other sounds in the codebase, as these other sounds might be played at reduced volume in the game. Check where these sound files are used and, if lower volume is specified, take that into account.  
If sound you're using as a reference is played at 60% volume in the game, it is sufficient to amplify your quiter sound to 60% of amplitude peaks of the reference, and then play it at 100% volume in the game.

Sound amplification is especially prone to introducing artifacts and distortions, so use it moderately and when absolutely necessary. It is always preferrable to find a clean loud audio sample than to amplify a quiet one to the desired level.
