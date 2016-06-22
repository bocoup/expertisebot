import {query} from '../../services/db';

// =============
// QUERY HELPERS
// =============

// Error-throwing helper function for bot promise chains.
export function abort(...args) {
  const error = new Error();
  error.abortData = args;
  return error;
}

// Find matching expertises for the given search term.
export function findExpertiseByName(teamId, search) {
  return query.expertiseByName({teamId, search}).then(matches => {
    let exact;
    if (matches.length > 0) {
      exact = matches.find(m => m.name.toLowerCase() === search.toLowerCase());
    }
    return {
      // All matches.
      matches,
      // The "best" match. Might not be exact.
      match: exact || matches[0],
      // An exact match. (case-insensitive)
      exact: exact || null,
    };
  });
}

// Find the best match for the given search term, and complain if necessary.
export function findExpertiseAndHandleErrors(teamId, search) {
  const output = [];
  return findExpertiseByName(teamId, search).then(({matches, match, exact}) => {
    if (matches.length === 0) {
      throw abort(`_No matches found for expertise "${search}"._`);
    }
    else if (matches.length === 1) {
      output.push(`_You specified "${search}", which matches: *${matches[0].name}*._`);
    }
    else {
      const expertiseList = matches.map(expertise => expertise.name).join(', ');
      output.push(`_Multiple matches were found: ${expertiseList}._`);
      if (exact) {
        output.push(`_You specified "${search}", which matches: *${exact.name}*._`);
      }
      else {
        throw abort(`_You specified "${search}", which is ambiguous. Please be more specific._`);
      }
    }
    return {
      matches,
      match,
      exact,
      output,
    };
  })
  .catch(error => {
    // If abort was used, re-throw with abort so the output propagates!
    if (error.abortData) {
      throw abort(...output, error.abortData);
    }
    throw error;
  });
}

export function getIntExpScales() {
  return query.expertiseScales()
  .then(results => results.reduce((memo, {type, description, ranking}) => {
    if (!memo[type]) {
      memo[type] = {};
    }
    memo[type][ranking] = description;
    return memo;
  }, {}));
}
