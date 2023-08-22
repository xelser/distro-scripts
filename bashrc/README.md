# BASHRC configs

## Text Types
- Normal Text: `0`
- Bold or Light Text: `1` 
> It depends on the terminal emulator.
- Dim Text: `2`
- Underlined Text: `4`
- Blinking Text: `5` 
> This does not work in most terminal emulators.
- Reversed Text: `7` 
> This inverts the foreground and background colors, so you’ll see black text on a white background if the current text is white text on a black background.
- Hidden Text: `8`

## Text Colors
Black: `30`
Blue: `34`
Cyan: `36`
Green: `32`
Purple: `35`
Red: `31`
White: `37`
Yellow: `33`

## Text Inputs
- A bell character: `\a`
- The date, in “Weekday Month Date” format (e.g., “Tue May 26”): `\d`
> The format is passed to strftime(3) and the result is inserted into the prompt string; an empty format results in a locale-specific time representation. The braces are required: `\D{format}`
- An escape character: `\e`
- The hostname, up to the first ‘.’: `\h`
- The hostname: `\H`
- The number of jobs currently managed by the shell: `\j`
- The basename of the shell’s terminal device name: `\l`
- A newline: `\n`
- A carriage return: `\r`
- The name of the shell, the basename of $0 (the portion following the final slash): `\s`
- The time, in 24-hour HH:MM:SS format: `\t`
- The time, in 12-hour HH:MM:SS format: `\T`
- The time, in 12-hour am/pm format: `\@`
- The time, in 24-hour HH:MM format: `\A`
- The username of the current user: `\u`
- The version of Bash (e.g., 2.00): `\v`
- The release of Bash, version + patchlevel (e.g., 2.00.0): `\V`
- The current working directory, with $HOME abbreviated with a tilde (uses the $PROMPT_DIRTRIM variable): `\w`
- The basename of $PWD, with $HOME abbreviated with a tilde: `\W`
- The history number of this command: `\!`
- The command number of this command: `\#`
- If the effective uid is 0, #, otherwise $: `\$`
- The character whose ASCII code is the octal value nnn: `\nnn`
- A backslash: `\\`
- Begin a sequence of non-printing characters: `\[`
> This could be used to embed a terminal control sequence into the prompt:.
- End a sequence of non-printing characters: `\]`
