# Tracker_HUD

Tracker HUD is an experimental Neovim plugin that displays a live code-awareness HUD based on the cursor position. It uses Tree-sitter to track the current function, nested scope depth, and branch context, giving a breadcrumb-style view of where the cursor is inside the code.

The long-term goal is to extend this into a systems-programming analysis HUD capable of tracking stack and heap state in assembly, unfreed pointers in C/C++, and ownership/lifetime status in Rust.
