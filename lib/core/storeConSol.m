function storeConSol(H)

% % Save initial volumes at convergence to be used in a next model run, to
% % speed up the next simulartion. Don't save if for some odd reason 
% volumes are complex, NaN or negative.

V = H.V;

if ( ~sum(isnan(V(:))) && isreal(V) && ~(sum(V(1,:)<0)) )
    V = H.V;
    ConSol.k = V(1,:)/H.Circ.SBV;
    save(fullfile(H.Misc.CMRootDir,'convergedSols/ConSol'), 'ConSol')
end