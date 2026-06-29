.pragma library

// ---- Unit tables ----
const UNIT_DATA = {
  // length (base: meter)
  mm: ['length', 0.001], cm: ['length', 0.01], m: ['length', 1], km: ['length', 1000],
  in: ['length', 0.0254], ft: ['length', 0.3048], yd: ['length', 0.9144], mi: ['length', 1609.344],
  nmi: ['length', 1852], au: ['length', 1.495978707e11],
  // mass (base: kilogram)
  mg: ['mass', 1e-6], g: ['mass', 0.001], kg: ['mass', 1],
  lb: ['mass', 0.45359237], oz: ['mass', 0.028349523125],
  t: ['mass', 1000], tonne: ['mass', 1000],
  // time (base: second)
  ms: ['time', 0.001], s: ['time', 1], sec: ['time', 1], min: ['time', 60],
  h: ['time', 3600], hr: ['time', 3600], day: ['time', 86400],
  week: ['time', 604800], year: ['time', 31557600], yr: ['time', 31557600],
  // volume (base: liter)
  ml: ['volume', 0.001], cl: ['volume', 0.01], l: ['volume', 1], m3: ['volume', 1000],
  gal: ['volume', 3.785411784], qt: ['volume', 0.946352946],
  pt: ['volume', 0.473176473], cup: ['volume', 0.2365882365],
  // data, decimal (base: byte, powers of 1000)
  b: ['data', 1], kb: ['data', 1000], mb: ['data', 1000 ** 2], gb: ['data', 1000 ** 3], tb: ['data', 1000 ** 4],
  // data, binary (base: byte, powers of 1024)
  kib: ['data', 1024], mib: ['data', 1024 ** 2], gib: ['data', 1024 ** 3], tib: ['data', 1024 ** 4],
};

const TEMP_ALIASES = {
  c: 'c', celsius: 'c',
  f: 'f', fahrenheit: 'f',
  k: 'k', kelvin: 'k',
};
const TEMP_CONV = {
  c: { toK: v => v + 273.15, fromK: k => k - 273.15 },
  f: { toK: v => (v - 32) * 5 / 9 + 273.15, fromK: k => (k - 273.15) * 9 / 5 + 32 },
  k: { toK: v => v, fromK: k => k },
};

const FUNCS = ['sin','cos','tan','asin','acos','atan','sqrt','abs','log2','log10','log','exp','round','floor','ceil','min','max','pow'];
const CONSTS = { pi: Math.PI, e: Math.E };

function lookupUnit(name) {
  const n = name.toLowerCase();
  if (UNIT_DATA[n]) return { dim: UNIT_DATA[n][0], unit: n };
  if (TEMP_ALIASES[n]) return { dim: 'temp', unit: TEMP_ALIASES[n] };
  return null;
}

function toBase(q) {
  if (q.dim === 'temp') return TEMP_CONV[q.unit].toK(q.value);
  return q.value * UNIT_DATA[q.unit][1];
}
function fromBase(baseVal, dim, unit) {
  if (dim === 'temp') return TEMP_CONV[unit].fromK(baseVal);
  return baseVal / UNIT_DATA[unit][1];
}

// ---- Tokenizer ----
function tokenize(s) {
  const tokens = [];
  const re = /\s*(\d+\.?\d*|[A-Za-z][A-Za-z0-9]*|\*\*|[+\-*/^(),])\s*/g;
  let m, lastIndex = 0;
  while ((m = re.exec(s)) !== null) {
    if (m.index !== lastIndex) throw new Error('unexpected character near "' + s.slice(lastIndex, m.index) + '"');
    let tok = m[1];
    if (tok === '**') tok = '^';
    if (/^\d/.test(tok)) tokens.push({ t: 'num', v: parseFloat(tok) });
    else if (/^[A-Za-z]/.test(tok)) tokens.push({ t: 'ident', v: tok });
    else tokens.push({ t: tok, v: tok });
    lastIndex = re.lastIndex;
  }
  if (lastIndex !== s.length) throw new Error('unexpected character near "' + s.slice(lastIndex) + '"');
  return tokens;
}

// ---- Parser / evaluator (recursive descent) ----
function parseExpr(tokens) {
  let pos = 0;
  const peek = () => tokens[pos];
  const next = () => tokens[pos++];

  function parseAddSub() {
    let left = parseMulDiv();
    while (peek() && (peek().t === '+' || peek().t === '-')) {
      const op = next().t;
      const right = parseMulDiv();
      left = op === '+' ? add(left, right) : sub(left, right);
    }
    return left;
  }
  function parseMulDiv() {
    let left = parsePow();
    while (peek() && (peek().t === '*' || peek().t === '/')) {
      const op = next().t;
      const right = parsePow();
      left = op === '*' ? mul(left, right) : div(left, right);
    }
    return left;
  }
  function parsePow() {
    let base = parseUnary();
    if (peek() && peek().t === '^') {
      next();
      const exp = parseUnary();
      base = pow(base, exp);
    }
    return base;
  }
  function parseUnary() {
    if (peek() && peek().t === '-') {
      next();
      const v = parseUnary();
      return { value: -v.value, dim: v.dim, unit: v.unit };
    }
    return parsePrimary();
  }
  function parsePrimary() {
    const tok = peek();
    if (!tok) throw new Error('unexpected end of expression');

    if (tok.t === '(') {
      next();
      const v = parseAddSub();
      if (!peek() || peek().t !== ')') throw new Error('missing closing parenthesis');
      next();
      return v;
    }
    if (tok.t === 'num') {
      next();
      let value = tok.v;
      // check for an attached unit (number immediately followed by an identifier
      // that isn't itself a function call)
      if (peek() && peek().t === 'ident') {
        const isFuncCall = tokens[pos + 1] && tokens[pos + 1].t === '(';
        if (!isFuncCall) {
          const u = lookupUnit(peek().v);
          if (u) {
            next();
            return { value, dim: u.dim, unit: u.unit };
          }
        }
      }
      return { value, dim: null, unit: null };
    }
    if (tok.t === 'ident') {
      next();
      const name = tok.v.toLowerCase();
      if (peek() && peek().t === '(') {
        next(); // consume '('
        const args = [];
        if (!peek() || peek().t !== ')') {
          args.push(parseAddSub());
          while (peek() && peek().t === ',') { next(); args.push(parseAddSub()); }
        }
        if (!peek() || peek().t !== ')') throw new Error('missing closing parenthesis in function call');
        next();
        if (!FUNCS.includes(name)) throw new Error('unknown function "' + name + '"');
        args.forEach(a => { if (a.dim !== null) throw new Error('"' + name + '()" does not accept quantities with units'); });
        const nums = args.map(a => a.value);
        let result;
        if (name === 'min' || name === 'max' || name === 'pow') result = Math[name].apply(null, nums);
        else result = Math[name](nums[0]);
        return { value: result, dim: null, unit: null };
      }
      if (name in CONSTS) return { value: CONSTS[name], dim: null, unit: null };
      throw new Error('unknown identifier "' + name + '"');
    }
    throw new Error('unexpected token "' + tok.v + '"');
  }

  const result = parseAddSub();
  if (pos !== tokens.length) throw new Error('unexpected token "' + tokens[pos].v + '"');
  return result;
}

function add(a, b) {
  if (a.dim === null && b.dim === null) return { value: a.value + b.value, dim: null, unit: null };
  if (a.dim !== b.dim) throw new Error('cannot add/subtract incompatible units');
  const sum = toBase(a) + toBase(b);
  return { value: fromBase(sum, a.dim, a.unit), dim: a.dim, unit: a.unit };
}
function sub(a, b) {
  if (a.dim === null && b.dim === null) return { value: a.value - b.value, dim: null, unit: null };
  if (a.dim !== b.dim) throw new Error('cannot add/subtract incompatible units');
  const diff = toBase(a) - toBase(b);
  return { value: fromBase(diff, a.dim, a.unit), dim: a.dim, unit: a.unit };
}
function mul(a, b) {
  if (a.dim === null && b.dim === null) return { value: a.value * b.value, dim: null, unit: null };
  if (a.dim === null) return { value: a.value * b.value, dim: b.dim, unit: b.unit };
  if (b.dim === null) return { value: a.value * b.value, dim: a.dim, unit: a.unit };
  throw new Error('multiplying two quantities with units isn\'t supported');
}
function div(a, b) {
  if (a.dim === null && b.dim === null) return { value: a.value / b.value, dim: null, unit: null };
  if (b.dim === null) return { value: a.value / b.value, dim: a.dim, unit: a.unit };
  if (a.dim === null) throw new Error('can\'t divide a number by a quantity with units');
  if (a.dim === b.dim) return { value: toBase(a) / toBase(b), dim: null, unit: null };
  throw new Error('dividing different unit types isn\'t supported');
}
function pow(a, b) {
  if (a.dim !== null || b.dim !== null) throw new Error('can\'t raise a quantity with units to a power');
  return { value: Math.pow(a.value, b.value), dim: null, unit: null };
}

// ---- Top level: handle "expr to targetUnit" ----
function evaluate(input) {
  const str = input.trim();
  if (str.length === 0) return '';

  const toMatch = str.match(/^(.*?)\bto\b(.*)$/i);
  const exprStr = toMatch ? toMatch[1] : str;
  const targetStr = toMatch ? toMatch[2].trim() : null;

  const tokens = tokenize(exprStr);
  const result = parseExpr(tokens);

  if (targetStr) {
    const target = lookupUnit(targetStr);
    if (!target) throw new Error('unknown target unit "' + targetStr + '"');
    if (result.dim === null) throw new Error('the left side has no unit to convert');
    if (target.dim !== result.dim) throw new Error('can\'t convert ' + (result.unit||'number') + ' to ' + target.unit + ' (different unit types)');
    const base = toBase(result);
    const converted = fromBase(base, target.dim, target.unit);
    return formatNum(converted) + ' ' + target.unit;
  }

  if (result.dim !== null) return formatNum(result.value) + ' ' + result.unit;
  return formatNum(result.value);
}

function formatNum(n) {
  if (Object.is(n, -0)) n = 0;
  if (n === 0) return '0';
  const rounded = Number(n.toPrecision(8));
  return rounded.toString();
}
