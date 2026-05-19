# Visual Eyes Demo Script

This demo showcases how **Visual Eyes** transforms the development experience by giving Claude multimodal vision.

## Introduction
Visual Eyes allows Claude Code to capture and analyze screenshots of your running application. No more describing CSS bugs - just let Claude see them.

---

## Scenario 1: The "Quick Look"
**Goal:** Verify that the application is running and the basic layout is correct.

**Prompt:**
> "Take a look at the homepage at localhost:3000 and tell me if the hero section looks aligned."

**Expected Output:**
- Visual Eyes captures a screenshot of the homepage.
- Claude analyzes the image.
- **Claude:** "I've captured the homepage. The hero section title is correctly centered, but I noticed the 'Get Started' button has a slightly inconsistent border-radius compared to the other components. Would you like me to fix that?"

---

## Scenario 2: Responsive Check
**Goal:** Verify the layout on different devices simultaneously.

**Prompt:**
> "Show me how the dashboard looks on mobile, tablet, and desktop side by side."

**Expected Output:**
- Visual Eyes captures three screenshots using different viewports (iPhone 13, iPad, Desktop).
- Claude displays the images or provides a summary.
- **Claude:** "Here are the responsive views. On mobile (iPhone 13), the sidebar correctly collapses into a hamburger menu. However, on tablet (iPad), the search bar is overlapping with the user profile icon. I can adjust the media queries to fix this layout collision."

---

## Scenario 3: The "See-Fix-Verify" Loop
**Goal:** Identify a visual bug, fix the code, and verify the result visually.

**Prompt:**
> "There's a visual bug on the /settings page where the toggle switches are overlapping the labels. Find and fix it."

**Step-by-Step Action:**
1. **Screenshot:** Visual Eyes captures `/settings`.
2. **Analysis:** Claude sees the `flex-direction` issue or missing `gap`.
3. **Fix:** Claude edits `src/components/SettingsToggle.tsx`.
4. **Verification:** Visual Eyes captures a *new* screenshot.
5. **Confirmation:**
   - **Claude:** "I've fixed the overlap by adding `gap-4` to the flex container and ensuring `align-items: center` is set. I've verified the fix with a new screenshot - the toggles are now perfectly aligned with their labels. Anything else?"

---

## Scenario 4: Visual Regression Testing
**Goal:** Ensure a CSS refactor didn't break anything else.

**Prompt:**
> "I've just refactored the global button styles. Compare the homepage before and after my changes to make sure I didn't break the layout."

**Step-by-Step Action:**
1. **Initial State:** Visual Eyes uses a cached or previous screenshot (if available) or takes one before a change.
2. **Comparison:** Visual Eyes generates a pixel-diff.
3. **Feedback:**
   - **Claude:** "I've compared the current state with the previous one. The buttons now have the new primary color as expected. I've also detected a 2px shift in the footer - it seems the new padding on buttons pushed the content down slightly. Do you want me to adjust the footer margins to compensate?"

---

## Conclusion
Visual Eyes eliminates the guesswork in UI development. By bridging the gap between code and pixels, it allows for a much faster and more reliable development cycle.

---
*Created by Nikolas de Hor in Goiânia.*
