# CodeBorn

A Windows 1v1 LAN tower-defense graybox built with Godot 4.6 and typed GDScript. One player trains bugs; the other builds defenses on twelve fixed nodes. Play a configurable 10–15 minute match, answer Arcane questions for gold, then rematch with swapped roles.

## Run

1. Install **Godot 4.6 stable**, tested build `89cea1439`, and import `project.godot`.
2. Press F6 on an individual screen only for isolated UI work; **F5** starts the full application.
3. Play → Host Game on the first instance. On the other, choose the discovered lobby or enter the host's IPv4 and game port. Local two-instance testing uses `127.0.0.1`.
4. Both players press Ready; the host presses Start Game. Roles reveal for five synchronized seconds, followed by 15 seconds preparation.
5. Defender: click a numbered deployment node, then buy a Pulse Spire. Attacker: buy Core Runner squads; two training lanes spawn completed orders. Hover ability buttons for their effects; at most two choices are allowed.
6. The attacker wins by destroying the core; the defender wins by surviving. Both players must select Rematch to swap roles. Main Menu disconnects and clears the session.

The Compatibility renderer is selected for broad Windows hardware support. No plugins, external runtime services, or paid assets are required to play. Final art and audio are replaceable placeholders; this build contains one functional tower and one troop archetype.

## Windows build

Install matching `4.6.stable` export templates. Run:

```powershell
./tools/export-windows.ps1 -Godot 'C:/path/to/Godot_v4.6-stable_win64_console.exe'
```

Copy the **entire `builds/windows` folder**, including `CodeBorn.exe` and `CodeBorn.pck`, to the second PC. Launch `CodeBorn.exe`; the editor is not required. Builds are ignored by Git. The export excludes test scripts and documentation.

## LAN / hotspot testing

Use the same build and question pack on both PCs. Connect both to the same ordinary Wi-Fi network, or connect the second PC to a Windows/mobile hotspot. Host and client need local reachability; sharing an SSID alone does not guarantee it. Allow the game through Windows Firewall for the trusted private network when prompted. Do not disable the firewall.

Default UDP ports: **24560 gameplay**, **24561 discovery**. The browser accepts a custom gameplay port if the default is occupied. Enter the same port on the joining PC. Discovery failure leaves manual IP joining available. Use `ipconfig` to identify the host's Wi-Fi/hotspot IPv4; ignore unrelated VPN/virtual adapters. Guest Wi-Fi/client isolation can block both discovery and direct joining. Same-LAN play needs neither internet access nor router port forwarding.

Test each player as network host and each gameplay role. Test full rooms, invalid addresses, disconnect before/during a match, base destruction, survival, role swapping, and menu cleanup. Localhost tests do not replace the two-physical-PC M1 acceptance gate.

## Settings and questions

Settings save locally under Godot's `user://settings.cfg`. On Windows the default folder is `%APPDATA%/Godot/app_userdata/CodeBorn`. Developer edits and validates a JSON question pack at `user://questions.json`; both PCs must have identical content. The included three-question beginner GDScript 4.6 pack is a prototype. No submitted code is executed. See [question authoring](docs/questions.md) and the [JSON schema](resources/data/question.schema.json).

## Verify and contribute

```powershell
./tools/verify.ps1 -Godot 'C:/path/to/Godot_v4.6-stable_win64_console.exe'
```

The runner imports the project, tests rules/settings, exercises navigation, captures both target resolutions, runs two real localhost processes through two matches, compares final states, and checks connection failures. Gameplay time is accelerated only by the dedicated test harness, using the same fixed simulation ticks; no cheat command is exposed in the game. Evidence is written to ignored `tests/artifacts`.

- [Architecture and contributor boundaries](docs/architecture.md)
- [Frozen rules and reference differences](docs/rules.md)
- [Network authority and messages](docs/network.md)
- [Miro UI inventory](docs/miro-ui-inventory.md)
- [Character placeholders and asset contract](docs/asset-contract.md)
- [Contribution and branch workflow](CONTRIBUTING.md)
- [Verification and acceptance matrix](docs/verification.md)
- [Known limitations](docs/known-limitations.md)

Planning references: [GitHub Project](https://github.com/users/JetJustineEspanola/projects/1/views/2), [Miro board](https://miro.com/app/board/uXjVHq86R4M=/), and the locally supplied `CodeBorn_Detailed_Development_Plan.docx`. The original backlog files were not present; the existing GitHub issues supply milestone acceptance criteria.
