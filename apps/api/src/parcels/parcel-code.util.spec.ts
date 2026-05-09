import {
  extractTrackingCandidate,
  normalizeCode,
  phoneSearchValue,
} from './parcel-code.util';

describe('parcel-code.util', () => {
  it('normalizes scanned codes', () => {
    expect(normalizeCode(' th 123  ')).toBe('TH123');
  });

  it('extracts tracking codes from QR urls', () => {
    expect(
      extractTrackingCandidate('https://example.com/track?tracking=abc123'),
    ).toBe('abc123');
    expect(
      extractTrackingCandidate('https://example.com/t/PTS-TH-20260509-0001'),
    ).toBe('PTS-TH-20260509-0001');
  });

  it('keeps loose phone digits searchable', () => {
    expect(phoneSearchValue('020 555-1234')).toBe('0205551234');
  });
});
