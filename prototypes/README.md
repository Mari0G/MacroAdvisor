# MacroAdvisor UI prototype

Throwaway prototype for comparing three Flutter-feasible visual directions.

Double-click `PROTOTYP_STARTEN.cmd`. It starts a small local-only server and opens
the prototype explicitly in Microsoft Edge (or Google Chrome as fallback). This
avoids app preview handlers that remove CSS and JavaScript.

The prototype is one self-contained HTML file with inline CSS and guarded startup
code. It works both through the launcher and when the HTML is opened directly.

Manual alternative:

```powershell
node .\prototypes\serve_prototype.js
```

The operating system assigns a fresh free port on every start. The server prints
the exact `PROTOTYPE_URL` and opens that address, so an older background server or
browser tab cannot capture the new run.

- `?variant=A`: calm, conventional Material-friendly layout
- `?variant=B`: warm editorial layout with sharper geometry
- `?variant=C`: data-focused dark layout with compact navigation

Variant C adds four color options, selectable in the floating palette bar or by
URL: `&palette=lime`, `&palette=ocean`, `&palette=coral`, and `&palette=violet`.

Use the floating arrows or keyboard Left/Right to switch. The prototype includes Today, capture source selection, text capture, review, save, meal detail, goals, history, and settings. All state is in memory.
