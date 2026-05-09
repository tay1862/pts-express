export function normalizeCode(value: string): string {
  return value.trim().replace(/\s+/g, '').toUpperCase();
}

export function extractTrackingCandidate(rawValue: string): string {
  const value = rawValue.trim();
  if (!value) {
    return value;
  }

  try {
    const url = new URL(value);
    const candidates = [
      url.searchParams.get('tracking'),
      url.searchParams.get('trackingCode'),
      url.searchParams.get('track'),
      url.searchParams.get('code'),
      url.pathname.split('/').filter(Boolean).at(-1),
    ];
    return candidates.find((candidate) => !!candidate)?.trim() ?? value;
  } catch {
    return value;
  }
}

export function phoneSearchValue(value?: string): string | undefined {
  if (!value) {
    return undefined;
  }
  const normalized = value.replace(/[^\d+]/g, '');
  return normalized || value.trim();
}
