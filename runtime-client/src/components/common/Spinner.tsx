import React from "react";
import { ClipLoader } from "react-spinners";

const override: React.CSSProperties = {
  display: "block",
  margin: "100px auto",
};

interface SpinnerProps {
  loading: boolean;
  className?: string;
}

const Spinner: React.FC<SpinnerProps> = ({ loading }) => {
  return (
    <ClipLoader
      color="#ea580c"
      loading={loading}
      cssOverride={override}
      size={150}
    />
  );
};

export default Spinner;
