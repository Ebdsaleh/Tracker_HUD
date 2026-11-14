@echo off
setlocal EnableExtensions

rem Tracker_HUD cumulative ERIDU test runner.
rem Run from anywhere; the script changes to the repository root.
rem
rem Results are shown in the console and overwritten on each run at:
rem   %USERPROFILE%\Desktop\trackerHUD_test_results.txt
rem
rem MAINTENANCE RULE:
rem   Append each tranche's new tests to the END of the call list below.
rem   Preserve -u NONE for pure tests and normal Neovim for parser-backed tests.
rem   This runner is fail-fast: the first RED test stops the suite.

set "TRACKER_HUD_RESULTS=%USERPROFILE%\Desktop\trackerHUD_test_results.txt"
set "TRACKER_HUD_TEMP=%TEMP%\trackerHUD_test_output_%RANDOM%_%RANDOM%.txt"

if not exist "%USERPROFILE%\Desktop" (
    echo [FAIL] Desktop directory not found: "%USERPROFILE%\Desktop"
    exit /b 1
)

> "%TRACKER_HUD_RESULTS%" echo [Tracker_HUD] Test run started: %DATE% %TIME%
>> "%TRACKER_HUD_RESULTS%" echo [Tracker_HUD] Results file: %TRACKER_HUD_RESULTS%
>> "%TRACKER_HUD_RESULTS%" echo.

echo [Tracker_HUD] Results will be written to:
echo   %TRACKER_HUD_RESULTS%
echo.

pushd "%~dp0.."
if errorlevel 1 (
    echo [FAIL] Could not enter Tracker_HUD repository root.
    exit /b 1
)

echo [Tracker_HUD] Running 140 tests...

call :run_none "tests/architecture_registry_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/architecture_alias_benchmark.lua"
if errorlevel 1 goto :fail
call :run_none "tests/adapter_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/section_inspect_colors_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/c_cpp_parser_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/c_cpp_source_directives_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/c_cpp_memory_observation_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_focus_regression.lua"
if errorlevel 1 goto :fail
call :run_none "tests/normalized_fact_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/presentation_modes_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/byte_diagram_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_alias_diagram_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/persistent_register_diagram_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/diagram_highlight_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/partial_value_mask_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_value_mask_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/x86_alias_write_state_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/diagram_mnemonic_persistence_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/architecture_target_overlay_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/architecture_register_roles_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/integer_value_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/wide_integer_inference_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/integer_width_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/x86_width_policy_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/x86_width_wrap_state_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/integer_operand_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/x86_immediate_policy_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/effect_semantic_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/x86_immediate_interpretation_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/x86_alias_read_state_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_address_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_adapter_contract_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_memory_structure_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/test_runtime_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_access_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_memory_access_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/effective_address_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_effective_address_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/address_size_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/x86_address_size_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/source_symbol_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_source_symbol_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_address_prefix_probe.lua"
if errorlevel 1 goto :fail
call :run_none "tests/machine_address_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_address_prefix_semantics_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_machine_address_evidence_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_address_prefix_relative_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_source_evidence_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_inspect_memory_target_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_instruction_relative_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_source_fact_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_source_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/operand_metadata_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_source_occurrence_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_source_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_index_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_source_metadata_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/line_summary_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_effect_index_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_effect_index_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_event_index_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_instruction_event_index_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_effect_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_effect_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/effect_match_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_effect_match_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_source_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_stack_effects_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_stack_register_carry_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_read_depth_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_boundary_effects_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_event_collection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/syntax_spec_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/asm_syntax_spec_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_parser_dispatch_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_instruction_parser_dispatch_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_primitives_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_primitives_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/branch_presentation_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_branch_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/construct_spec_validation_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_construct_validation_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/construct_source_identity_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_construct_identity_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/construct_parser_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_construct_parser_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_state_read_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_state_read_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_value_policy_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_value_policy_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_processing_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_processing_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_value_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_value_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_effect_match_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_stack_effect_match_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_fact_builder_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_fact_builder_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_state_write_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_state_write_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_event_fact_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_instruction_event_fact_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_effect_apply_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_effect_apply_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_stack_effect_apply_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_register_context_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_boundary_register_context_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_apply_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_apply_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_address_evaluator_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_memory_address_evaluator_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/rule_syntax_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/asm_rule_syntax_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_selection_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_selection_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/memory_source_discovery_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_memory_source_discovery_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_source_discovery_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_source_discovery_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_boundary_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/instruction_event_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_instruction_event_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/stack_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_stack_effect_pipeline_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/context_engine_facade_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/analysis_profile_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/analysis_profile_report_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/analysis_profile_command_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_performance_baseline_sample_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_context_profile_subphases_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/relative_address_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/treesitter_field_access_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/register_effect_replay_session_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_register_effect_replay_parity_smoke.lua"
if errorlevel 1 goto :fail
call :run_none "tests/boundary_register_replay_session_smoke.lua"
if errorlevel 1 goto :fail
call :run_config "tests/asm_boundary_register_replay_parity_smoke.lua"
if errorlevel 1 goto :fail

echo [GREEN] Tracker_HUD test suite passed: 140/140
>> "%TRACKER_HUD_RESULTS%" echo [GREEN] Tracker_HUD test suite passed: 140/140
echo.
echo [Tracker_HUD] Results saved to:
echo   %TRACKER_HUD_RESULTS%
del /q "%TRACKER_HUD_TEMP%" >nul 2>&1
popd
exit /b 0

:run_none
echo [TEST] %~1
>> "%TRACKER_HUD_RESULTS%" echo [TEST] %~1
nvim --headless -u NONE -c "lua local ok, err = pcall(vim.cmd, 'luafile ' .. vim.fn.fnameescape([[%~1]])); if not ok then io.stderr:write(tostring(err) .. string.char(10)); vim.cmd('cquit 1') end" -c "qa!" > "%TRACKER_HUD_TEMP%" 2>&1
set "TEST_EXIT=%errorlevel%"
type "%TRACKER_HUD_TEMP%"
type "%TRACKER_HUD_TEMP%" >> "%TRACKER_HUD_RESULTS%"
if not "%TEST_EXIT%"=="0" exit /b %TEST_EXIT%
exit /b 0

:run_config
echo [TEST] %~1
>> "%TRACKER_HUD_RESULTS%" echo [TEST] %~1
nvim --headless -c "lua local ok, err = pcall(vim.cmd, 'luafile ' .. vim.fn.fnameescape([[%~1]])); if not ok then io.stderr:write(tostring(err) .. string.char(10)); vim.cmd('cquit 1') end" -c "qa!" > "%TRACKER_HUD_TEMP%" 2>&1
set "TEST_EXIT=%errorlevel%"
type "%TRACKER_HUD_TEMP%"
type "%TRACKER_HUD_TEMP%" >> "%TRACKER_HUD_RESULTS%"
if not "%TEST_EXIT%"=="0" exit /b %TEST_EXIT%
exit /b 0

:fail
set "TEST_EXIT=%errorlevel%"
echo [RED] Tracker_HUD test suite stopped on failure.
>> "%TRACKER_HUD_RESULTS%" echo [RED] Tracker_HUD test suite stopped on failure.
echo.
echo [Tracker_HUD] Results saved to:
echo   %TRACKER_HUD_RESULTS%
del /q "%TRACKER_HUD_TEMP%" >nul 2>&1
popd
exit /b %TEST_EXIT%
