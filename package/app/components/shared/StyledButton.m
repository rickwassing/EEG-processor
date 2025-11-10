% STYLEDBUTTON
% A custom-styled button for consistent UI styling.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2025-02-21, Rick Wassing
%
% EEG-Processor (C) 2025 by Rick Wassing is licensed under CC BY-NC-SA 4.0.
% View the license at https://creativecommons.org/licenses/by-nc-sa/4.0.

classdef StyledButton < handle
    % #####################################################################
    % PROPERTIES
    % =====================================================================
    % Public properties that users have access to
    properties
        style struct % Struct containing styling properties
        handle % Handle to the button object
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Constructor
    methods
        function Obj = StyledButton(parent, variant, style, varargin)
            try
                % Extract the varargin from the parent's user-data
                props = parsevarargin(varargin);
                props.variant = Obj.getVariant(variant);
                % Constructor
                Obj.handle = uibutton(parent, varargin{:});
                % Store the style
                Obj.style = style;
                Obj.handle.Text = Obj.getStyledText(Obj.handle.Text);
                Obj.handle.FontName = style.typography.base.font;
                Obj.handle.FontSize = style.typography.base.size;
                Obj.handle.FontWeight = style.typography.button.fontWeight;
                Obj.handle.FontColor = ifelse(ismember(props.variant, {'warning', 'info', 'light'}), '#000000', '#FFFFFF');
                Obj.handle.BackgroundColor = style.colors.button.(props.variant);
            catch ME
                printerrormessage(ME, sprintf('The error occurred during ''constructor'' in %s.', mfilename('class')))
            end
        end
    end
    % #####################################################################
    % METHODS
    % =====================================================================
    % Helper method to apply text styling
    methods (Access = private)
        % Extracts the variant for this button
        function variant = getVariant(Obj, props) %#ok<INUSD>
            if ~isfield(props, 'variant')
                variant = 'primary';
            else
                switch lower(props.variant)
                    case {'primary', 'secondary', 'success', 'error', 'warning', 'info', 'light', 'dark'}
                        variant = props.variant;
                    otherwise
                        variant = 'primary';
                end
            end
        end
        % Apply text style based on font variant
        function styledText = getStyledText(Obj, text)
            if ~isfield(Obj.style.typography.button, 'fontVariant')
                styledText = text;
            else
                switch lower(Obj.style.typography.button.fontVariant)
                    case 'none'
                        styledText = text;
                    case 'lowercase'
                        styledText = lower(text);
                    case 'all-caps'
                        styledText = upper(text);
                    otherwise
                        styledText = text;
                end
            end
        end
    end
end