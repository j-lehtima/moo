%% Test extract_design_variables()

fprintf('Testing extract_design_variables()...\n\n');

config = design_variables_config();
fprintf('✓ Config loaded\n\n');

[all_params, varying_names, varying_ranges, varying_n_points, fixed_names] = ...
    extract_design_variables(config);

fprintf('Results:\n');
fprintf('  all_params class: %s\n', class(all_params));
fprintf('  all_params fields:\n');
field_list = fieldnames(all_params);
for i = 1:length(field_list)
    fprintf('    - %s = %f\n', field_list{i}, all_params.(field_list{i}));
end

fprintf('\n');
fprintf('  varying_names class: %s, content:\n', class(varying_names));
for i = 1:length(varying_names)
    fprintf('    - %s\n', varying_names{i});
end

fprintf('\n');
fprintf('  varying_ranges class: %s, content:\n', class(varying_ranges));
for i = 1:length(varying_ranges)
    fprintf('    - [%.2f, %.2f]\n', varying_ranges{i}(1), varying_ranges{i}(2));
end

fprintf('\n');
fprintf('  varying_n_points class: %s, content:\n', class(varying_n_points));
fprintf('    %s\n', mat2str(varying_n_points));

fprintf('\n');
fprintf('  fixed_names class: %s, content:\n', class(fixed_names));
for i = 1:length(fixed_names)
    fprintf('    - %s\n', fixed_names{i});
end

fprintf('\n✓ All tests completed\n');
