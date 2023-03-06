classdef ObjectPool < handle
    % *********************************************************************
    % PROPERTIES
    properties
        hParent;
        Pool;
    end
    % *********************************************************************
    % METHODS
    methods (Access = public)
        % =================================================================
        function h = ObjectPool(Parent)
            h.hParent = Parent;
        end
        % =================================================================
        % Pull an object from the pool, or create new if pool is empty
        function Singleton = pull(Obj, Parent)
            if ~isempty(Obj.hParent.Children)
                % Try to return a object from the pool
                Singleton = Obj.hParent.Children(end);
                Singleton.Parent = Parent;
            else
                Singleton = uitreenode(Parent, 'Text', 'uninit', 'UserData', struct('Slice', '', 'id', '')); % create a new object
            end
        end
        % =================================================================
        % Return the single object to the unused pool, once we are done with it
        function recycle(Obj, Singleton)
            Singleton.Parent = Obj.hParent;
        end
    end
end